class Map < ActiveRecord::Base
belongs_to :user
has_many :photos, dependent: :destroy

def hello
  self.image_uid="http://127.0.0.1:3000/photos/development/maps/#{self.id}.png"
  self.thumbnail_uid="http://127.0.0.1:3000/photos/development/maps/#{self.id}_20.png"
  IO.popen ("./generate.sh #{self.id}")
  self.latitude = self.photos.all.average('gps_latitude')
  self.longitude = self.photos.all.average('gps_longitude')
  self.taken_at = self.photos.first.taken_at
  self.complete=true
  self.save
end

end
