json.array!(@cameras) do |camera|
  json.extract! camera, :id, :name
  json.url camera_url(camera, format: :json)
end
