class MapsController < ApplicationController
  before_filter :check_session
  before_action :set_map, only: [:show, :edit, :update, :destroy]

  # GET /maps
  # GET /maps.json
  def index
    @maps = Map.where(user_id: current_user.id)
  end

  def generate
    @map = Map.find(params[:id])
    @map.checkCamera
    @map.queue
    respond_to do |format|
      format.html { redirect_to user_maps_path(params[:user_id]), notice: 'Map was successfully started.' }
    end
  end

  def rotate
    @map = Map.find(params[:id])
    @map.rotate(params[:rot])
    respond_to do |format|
      format.html { redirect_to edit_user_map_url(params[:user_id],params[:id]) }
    end
  end

  # GET /maps/1
  # GET /maps/1.json

  def show
    @map = Map.find(params[:id])
    @map.checkProcess
  end

  # GET /maps/new
  def new
    @map = Map.new
  end

  # GET /maps/1/edit
  def edit
  end

  # POST /maps
  # POST /maps.json
  def create
    @map = Map.new(map_params)

    respond_to do |format|
      if @map.save
        format.html { redirect_to new_user_map_photo_multiple_url(@map.user.id,@map), notice: 'Map was successfully created.' }
        format.json { render :show, status: :created, location: @map }
      else
        format.html { render :new }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /maps/1
  # PATCH/PUT /maps/1.json
  def update
    respond_to do |format|
      if @map.update(map_params)
        format.html { redirect_to @map, notice: 'Map was successfully updated.' }
        format.json { render :show, status: :ok, location: @map }
      else
        format.html { render :edit }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maps/1
  # DELETE /maps/1.json
  def destroy
    @map.killProcess
    @map.destroy
    respond_to do |format|
      format.html { redirect_to user_maps_url, notice: 'Map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_map
      @map = Map.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def map_params
      params.require(:map).permit(:title, :image_uid, :image_name, :user_id, :complete, :processing, :camera, :mapping_method_id, :latitude, :longitude, :bearing, :gallery, :gallery_gps, :public, :public_gps, :status, :failed)
    end
end
