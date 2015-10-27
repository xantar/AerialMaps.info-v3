class MappingMethodsController < ApplicationController
  before_filter :check_session
  before_action :set_mapping_method, only: [:show]

  # GET /mapping_methods
  # GET /mapping_methods.json
  def index
    @mapping_methods = MappingMethod.all
  end

  # GET /mapping_methods/1
  # GET /mapping_methods/1.json
  def show
  end

  # GET /mapping_methods/new
  def new
    @mapping_method = MappingMethod.new
  end

  # GET /mapping_methods/1/edit
  def edit
  end

  # POST /mapping_methods
  # POST /mapping_methods.json
  def create
    @mapping_method = MappingMethod.new(mapping_method_params)

    respond_to do |format|
      if @mapping_method.save
        format.html { redirect_to @mapping_method, notice: 'Mapping method was successfully created.' }
        format.json { render :show, status: :created, location: @mapping_method }
      else
        format.html { render :new }
        format.json { render json: @mapping_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mapping_methods/1
  # PATCH/PUT /mapping_methods/1.json
  def update
    respond_to do |format|
      if @mapping_method.update(mapping_method_params)
        format.html { redirect_to @mapping_method, notice: 'Mapping method was successfully updated.' }
        format.json { render :show, status: :ok, location: @mapping_method }
      else
        format.html { render :edit }
        format.json { render json: @mapping_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mapping_methods/1
  # DELETE /mapping_methods/1.json
  def destroy
    @mapping_method.destroy
    respond_to do |format|
      format.html { redirect_to mapping_methods_url, notice: 'Mapping method was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mapping_method
      @mapping_method = MappingMethod.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mapping_method_params
      params.require(:mapping_method).permit(:name)
    end
end
