namespace :db do
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    default_values
  end
end

def default_values
  default_cameras
  default_mapping_methods
end

def default_cameras
  Camera.create!( :name => "PHANTOM VISION FC200   ", :lens_profile => true )
end

def default_mapping_methods
  MappingMethod.create!( :name => "multirow" )
  MappingMethod.create!( :name => "prealigned" )
  MappingMethod.create!( :name => "linearmatch" )
end
