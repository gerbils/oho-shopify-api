require_relative "client"
require_relative "queries/metaobject"

module OhoShopifyApi::Metaobject
  extend self

  KNOWN_TYPES = []

  MO = OhoShopifyApi::Queries::Metaobject
  Client = OhoShopifyApi::Client


  def define(definition)
    do_define(definition)
  end

  def defined?(type)
    load_known_types() if KNOWN_TYPES.empty?
    KNOWN_TYPES.find {|kt| kt["type"] == type}
  end

  def delete(id)
    do_delete(id)
  end

  def find(type, handle) 
    do_find_by_handle(input_handle(handle, type))
  end

  def upsert(type, handle, fields)
    mo_handle = input_handle(handle, type)
    mapped_fields = fields.map {|k,v| { key: k, value: v }}
    metaobject = {
      handle: handle,
      fields: mapped_fields,
      capabilities: {
        publishable: {
          status: "ACTIVE"
        }
      }
    }
    do_upsert(mo_handle, metaobject)
  end

  private

  def load_known_types
    raw_result = Client.query(MO::FindAllTypes)
    result = raw_result.to_hash
    result.dig("data", "metaobjectDefinitions", "nodes").each do |mod|
      KNOWN_TYPES << mod
    end
  end

  def input_handle(handle, type)
    {
      handle: handle.to_s,
      type:   type,
    }
  end

  def do_define(definition)
    if defined?(definition[:type])
      puts "Skipping #{definition[:type]}: already defined"
      return
    end
    
    raw_result = Client.query(MO::Define, variables: { definition: definition })
    result = raw_result.to_hash
    pp result
    errors = result["errors"] || result["data"]["metaobjectDefinitionCreate"]["userErrors"]
    if errors && !errors.empty? 
      if errors.first["code"] == "TAKEN"
        puts "Skipping Metaobject definition: #{spec}"
      else
        pp errors
        exit 1
      end
    end
    sleep(0.02)
  end

  def do_delete(id)
    raw_result = Client.query(MO::Delete, variables: { id: id })
    result = raw_result.to_hash
    pp result
    errors = result["errors"] || result["data"]["metaobjectDelete"]["userErrors"]
    if errors && !errors.empty? 
      if errors.first["code"] == "TAKEN"
        puts "Skipping Metaobject definition: #{spec}"
      else
        pp errors
        exit 1
      end
    end
    sleep(0.02)
  end


  def do_upsert(mo_handle, metaobject)
    raw_result = Client.query(MO::Upsert, variables: { handle: mo_handle, metaobject: metaobject })
    result = raw_result.to_hash
    pp result
    errors = result["errors"] || result["data"]["metaobjectUpsert"]["userErrors"]
    if errors && !errors.empty? 
      pp errors
      exit 1
    end
    sleep(0.02)
  end

  def do_find_by_handle(mo_handle)
    raw_result = Client.query(MO::FindByHandle, variables: { handle: mo_handle })
    result = raw_result.to_hash
    mo = result.dig("data", "metaobjectByHandle")
    return nil unless mo
    hash = {
      "id" => mo["id"]
    }
    mo["fields"].each do |f|
      hash[f["key"]] = f["value"]
    end
    hash
  end

end


