class Photo < ActiveRecord::Base
belongs_to :map

  dragonfly_accessor :image do
      storage_options do |a|
          { path: "unproc/#{self.map_id}/#{self.image_name}" }
      end
  end

  validates :image, presence: true
  validates_size_of :image, maximum: 20.megabytes,
                    message: "should be no more than 20 MB", if: :image_changed?

  validates_property :format, of: :image, in: [:jpeg, :jpg], case_sensitive: false,
                     message: "should be either .jpg", if: :image_changed?
end
