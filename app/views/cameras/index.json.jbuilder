json.array!(@cameras) do |camera|
  json.extract! camera, :id, :string
  json.url camera_url(camera, format: :json)
end
