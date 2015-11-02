class Map < ActiveRecord::Base
belongs_to :user
has_many :photos, dependent: :destroy

def checkProcess
  res=system("./checkpid.sh #{self.id}")
  self.processing=res
  self.save
  res
end

def killProcess
  res=system("./killpid.sh #{self.id}")
  self.processing=false
  self.save
  res
end

def rotate(rot)
  self.bearing=Float(self.bearing)-Float(rot)
  self.processing=true
  self.save
  system("./rotate.sh #{self.id} #{self.bearing} &")
end

def calcBearing
  photo1 = self.photos.order('image_uid ASC').first
  photo2 = self.photos.order('image_uid ASC').second

  if photo1.gps_latitude!=nil && photo2.gps_latitude!=nil && photo1.gps_longitude!=nil && photo2.gps_longitude!=nil
    lat1 = (photo1.gps_latitude/180*Math::PI)
    lat2 = (photo2.gps_latitude/180*Math::PI)
    lon1 = (photo1.gps_longitude/180*Math::PI)
    lon2 = (photo2.gps_longitude/180*Math::PI)

    if ( lat1 == lat2 && lon1 == lon2 && self.photos.order('image_uid ASC').third )
      photo2 = self.photos.order('image_uid ASC').third
      lat2 = (photo2.gps_latitude/180*Math::PI)
      lon2 = (photo2.gps_longitude/180*Math::PI)
    end

    if ( lat1 == lat2 && lon1 == lon2 && self.photos.order('image_uid ASC').fourth )
      photo2 = self.photos.order('image_uid ASC').fourth
      lat2 = (photo2.gps_latitude/180*Math::PI)
      lon2 = (photo2.gps_longitude/180*Math::PI)
    end

    dlon = lon2 - lon1

    y = (Math.sin(dlon)*Math.cos(lat2))
    x = ((Math.cos(lat1)*Math.sin(lat2))-(Math.sin(lat1)*Math.cos(lat2)*Math.cos(dlon)))
    bearing=(Math.atan2(y,x))*(180/Math::PI) 
  else
    bearing=nil
  end
  bearing
end

def checkCamera
  if ( Camera.where( name: self.photos.first.camera ).count > 0 )
  else
    Camera.create!( :name => self.photos.first.camera )
  end
end

def queue
  if (self.photos.count >1)
    self.queued = true
    self.queued_at = Time.now
  # Clear previous Generate records to not have their processed reaped
    self.processing = false
    self.generated_at = nil
    self.save

    Map.scheduele
  end
end

def generate

  self.image_uid="http://aerialmaps.info/photos/maps/#{self.id}.png"
  self.thumbnail_uid="http://aerialmaps.info/photos/maps/#{self.id}_20.png"
  self.latitude = self.photos.all.average('gps_latitude')
  self.longitude = self.photos.all.average('gps_longitude')
# here We should determine if the camera exists, and if it doesn't lets create a new camera w/o lens profile
  self.camera = self.photos.first.camera
  self.checkCamera
  self.taken_at = self.photos.first.taken_at

  if ( !self.bearing ) 
    self.bearing=self.calcBearing
  end

  self.queued=false
  self.queued_at=nil
  self.generated_at=Time.now
  self.processing=true
  self.complete=true
  self.save

  system ("./generate.sh #{self.id} #{Camera.where(name: self.camera).first.id} #{MappingMethod.find(self.mapping_method_id).name} #{self.bearing} 2>&1 | tee public/debug/debug_generate_map_#{self.id} &")
end

def self.refresh
  Map.all.where(processing: true).each do |map|
    res = map.checkProcess
    if (res=false)
      map.processing=false
      map.save
    end
  end
end

def self.scheduele
  max_concurrent = 1  # Maximum number of maps generated at the same time

  Map.refresh

    while (Map.all.where( processing:  true ).count < max_concurrent && Map.all.where( queued:  true ).count > 0 ) do
      currentmap = Map.all.where( queued:  true ).order( 'queued_at ASC' ).first
      currentmap.generate
      Map.refresh
    end 

end

end
