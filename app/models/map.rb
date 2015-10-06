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
  self.processing=true
  system ("./generate.sh #{self.id} #{Camera.where(name: self.camera).first.id} 2>&1 | tee public/debug/debug_generate_map_#{self.id} &")
  self.complete=true
  self.save
end

end
