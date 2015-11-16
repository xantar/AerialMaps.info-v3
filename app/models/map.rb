class Map < ActiveRecord::Base
belongs_to :user
has_many :photos, dependent: :destroy

def checkStatus
  status = self.status
  case status
  when 0
    "Map Queued"
  when 1
    "Lens Profile Correction"
  when 2
    "Control Point Generation"
  when 3
    "Control Point Optomization"
  when 4
    "Panorama Optomization"
  when 5
    "Adjusted Image Generation"
  when 6
    "Combining Images"
  when 7      
    "Generating Final Image & Thumbnails"
  when 8      
    "Complete"
  when 98
    "Rotating Image"
  when 99
    "Error Rotating"
  else
    "Status: Unknown"
  end
			  
end

def checkProcess
  res=system("./checkpid.sh #{self.id}")
  self.processing=res
  if File.exists?("public/processing/#{self.id}/process.status")
    self.status=File.open("public/processing/#{self.id}/process.status").first.to_i
  end
  self.save
  if (self.status==0)
    self.processing=true
	self.save
  else
    self.processing
  end
end

def killProcess
  res=system("./killpid.sh #{self.id}")
  self.processing=false
  self.save
  res
end

def rotate(rot)
  self.bearing=((Float(self.bearing)+Float(rot))%360)
  if Float(self.bearing) < 0
    self.bearing=Float(self.bearing)+360
  end
  if File.exists?("public/processing/#{self.id}/process.status")
    File.delete("public/processing/#{self.id}/process.status")
  end

  system("./rotate.sh #{self.id} #{self.bearing} &")
  self.processing=true
  self.status=0
  self.failed=false
  self.save
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

    if ( lat1 == lat2 && lon1 == lon2 && self.photos.order('image_uid ASC').fifth )
      photo2 = self.photos.order('image_uid ASC').fifth
      lat2 = (photo2.gps_latitude/180*Math::PI)
      lon2 = (photo2.gps_longitude/180*Math::PI)
    end
	
    dlon = lon2 - lon1

    y = (Math.sin(dlon)*Math.cos(lat2))
    x = ((Math.cos(lat1)*Math.sin(lat2))-(Math.sin(lat1)*Math.cos(lat2)*Math.cos(dlon)))
    bearing=(Math.atan2(y,x))*(180/Math::PI) 
  else
    bearing=0
  end
  bearing=((Float(bearing))%360)
  if Float(bearing) < 0
    bearing=Float(bearing)+360
  end
  bearing
end

def checkCamera
  if ( Camera.where( name: self.photos.first.camera ).count > 0 )
  else
    Camera.create!( :name => self.photos.first.camera )
  end
end

def imageOrder
  if Dir.exists?("public/processing/#{self.id}")
  else
    system("mkdir public/processing/#{self.id}")
  end
  if File.exists?("public/processing/#{self.id}/image.order")
    File.delete("public/processing/#{self.id}/image.order")
  end
  File.open("public/processing/#{self.id}/image.order","w") do |file|
    self.photos.all.order( 'taken_at ASC' ).each do |image|
      file.puts "./#{image.image_name.downcase}\n"
    end  
	file.close
  end
end

def queue
  if ( self.photos.count >1 )
    if File.exists?("public/processing/#{self.id}/process.status")
      File.delete("public/processing/#{self.id}/process.status")
    end
	self.status=0
	self.failed=false
  
    self.queued = true
    self.queued_at = Time.now
  # Clear previous Generate records to not have their processed reaped
    self.processing = false
    self.generated_at = nil
    self.save

#    Map.scheduele
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

  #Generate Image.order for the project
  self.imageOrder
  system ("./generate.sh #{self.id} #{Camera.where(name: self.camera).first.id} #{MappingMethod.find(self.mapping_method_id).name} #{self.bearing} 2>&1 | tee public/debug/debug_generate_map_#{self.id} &")

  #Remove from the queue
  self.queued=false
  self.queued_at=nil
  #Add to active processes
  self.processing=true
  self.generated_at=Time.now
  #set Flags
  self.complete=true
  self.save  
end

def self.refresh
  Map.all.where(processing: true).each do |map|
    res = map.checkProcess
    if ( res==false && map.status > 0 )
      # Process finished so lets mark the object as finished
  	  map.processing=false
      # Check if status is Done? & if final file exists
	  #Check for final output file(s)
	  finalfile = "public/processing/#{map.id}/map.tif"
	  if ( File.exists?(finalfile) )
	    # Success! 
      else 
	    # Fail!
		map.failed=true
		map.complete=false
	  end
      map.save
    end
  end
end

def self.scheduele
  # This should be Close to the # of cores. but REMEMBER thumbnail generation and rotation take threads, so lower is more efficient. 
  Map.refresh

    while (Map.all.where( processing:  true ).count < Map.maxProcesses && Map.all.where( queued:  true ).count > 0 ) do
      currentmap = Map.all.where( queued:  true ).order( 'queued_at ASC' ).first
      currentmap.generate
      Map.refresh
    end 

end

def self.maxProcesses
    max_concurrent = 1  # Maximum number of maps generated at the same time
end

end
