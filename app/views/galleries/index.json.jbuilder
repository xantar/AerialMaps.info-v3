json.array!(@maps) do |map|
  json.extract! map, :id, :title, :image_uid, :image_name, :user_id, :complete
  json.url map_url(map, format: :json)
end
