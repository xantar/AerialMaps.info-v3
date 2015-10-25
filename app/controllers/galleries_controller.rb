class GalleriesController < ApplicationController

  def index
    @maps = Map.all.where( gallery: true )
  end

  def show
    @map = Map.find(params[:id])
  end

end
