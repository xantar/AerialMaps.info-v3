class PhotosController < ApplicationController
  before_filter :check_session

  def show
  end

  def new
    @photos = Photo.order('image_uid ASC')
    @photo = Photo.new
  end

  def new_multiple
    @photos = Photo.order('image_uid ASC')
    @photo = Photo.new
  end

  def create
    respond_to do |format|
      @photo = Photo.new(photo_params)
      @myexifr = EXIFR::JPEG.new("#{@photo.image.path}")
      @photo.save
      if @myexifr.try(:gps) 
        @photo.gps_latitude="#{@myexifr.gps.latitude}"
        @photo.gps_longitude="#{@myexifr.gps.longitude}"
      end
      @photo.camera="#{@myexifr.model}"
      @photo.taken_at="#{@myexifr.date_time_original}"
      @photo.save
      format.html { redirect_to new_photo_path }
      format.js
    end
  end

  def destroy
     @photo = Photo.find(params[:id])
     @photo.destroy
      respond_to do |format|
        format.html { redirect_to new_user_map_photo_multiple_url(params[:user_id],params[:map_id]), notice: 'Photo was successfully destroyed.' }
        format.json { head :no_content }
     end 
  end

  private

  def photo_params
    params.require(:photo).permit(:image, :user_id, :map_id)
  end
end
