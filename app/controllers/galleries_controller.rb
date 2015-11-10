class GalleriesController < ApplicationController
  before_filter :check_gallery, only: [:show]

  def index
    @maps = Map.all.where( gallery: true )
  end

  def show
    @map = Map.find(params[:id])
  end

  def check_gallery
    @map = Map.find(params[:id])
	if @map.gallery==false
	  if @current_user
	  then
	   redirect to user
	  else
	  redirect_to root_url
	  end
	end
  end
end
