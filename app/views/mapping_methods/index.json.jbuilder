json.array!(@mapping_methods) do |mapping_method|
  json.extract! mapping_method, :id, :name
  json.url mapping_method_url(mapping_method, format: :json)
end
