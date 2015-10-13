class Map < ActiveRecord::Base
belongs_to :user
has_many :photos, dependent: :destroy

def generate

  self.image_uid="http://aerialmaps.info:3000/photos/development/maps/#{self.id}.png"
  self.thumbnail_uid="http://aerialmaps.info:3000/photos/development/maps/#{self.id}_20.png"
  self.latitude = self.photos.all.average('gps_latitude')
  self.longitude = self.photos.all.average('gps_longitude')
  self.camera = self.photos.first.camera
  self.map_mode = "multirow"
  self.taken_at = self.photos.first.taken_at

# Lets calculate a bearing
  photo1 = self.photos.order('image_uid ASC').first
  photo2 = self.photos.order('image_uid ASC').second

  lat1 = (photo1.gps_latitude/180*Math::PI)
  lat2 = (photo2.gps_latitude/180*Math::PI)
  lon1 = (photo1.gps_longitude/180*Math::PI)
  lon2 = (photo2.gps_longitude/180*Math::PI)
  dlon = lon2 - lon1

  y = (Math.sin(dlon)*Math.cos(lat2))
  x = ((Math.cos(lat1)*Math.sin(lat2))-(Math.sin(lat1)*Math.cos(lat2)*Math.cos(dlon)))
  bearing=(Math.atan2(y,x))*(180/Math::PI)  

#  self.processing=true
#  system ("./generate.sh #{self.id} #{Camera.where(name: self.camera).first.id} 2>&1 | tee public/debug/debug_generate_map_#{self.id} &")
  self.complete=true
  self.save
end

end
