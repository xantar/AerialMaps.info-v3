class LinksController < ApplicationController
  before_filter :check_link, only: [:show]

  def show
    @map = Map.find(params[:id])
  end

  def check_link
    @map = Map.find(params[:id])
	if @map.public==false
	  if @current_user
	  then
	   redirect to user
	  else
	    redirect_to root_url
	  end
	end
  end
end
