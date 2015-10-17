class Map < ActiveRecord::Base
belongs_to :user
has_many :photos, dependent: :destroy

def checkProcess
  res=system("./checkpid.sh #{self.id}")
  self.processing=res
  self.save
  res
end


def generate

  self.image_uid="http://127.0.0.1:3000/photos/development/maps/#{self.id}.png"
  self.thumbnail_uid="http://127.0.0.1:3000/photos/development/maps/#{self.id}_20.png"
  self.latitude = self.photos.all.average('gps_latitude')
  self.longitude = self.photos.all.average('gps_longitude')
# here We should determine if the camera exists, and if it doesn't lets create a new camera w/o lens profile
  self.camera = self.photos.first.camera
  self.mapping_method_id = 1
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
  self.bearing=(Math.atan2(y,x))*(180/Math::PI)  
  

  self.processing=true
  self.complete=true
  self.save

  system ("./generate.sh #{self.id} #{Camera.where(name: self.camera).first.id} -#{self.bearing} 2>&1 | tee public/debug/debug_generate_map_#{self.id} &")
end

end
