class AttractionsController < ApplicationController
  before_action :set_attraction, only: [:show, :edit, :update, :destroy]

  def index
    @attractions = AttractionDecorator.decorate(Attraction.all)
  end

  def show
    @attractions = Attraction.where(visited: false)
    @hash = Gmaps4rails.build_markers(@attractions) do |attraction, marker|
      next if attraction.latitude.nil?
      marker.title attraction.name
      marker.infowindow "<a href='#{attraction.link}' target='_blank'>#{attraction.name}</a>

                         <p><a href='attractions/#{attraction.id}' data-method='delete'>Destroy</a></p>"
      marker.lat attraction.latitude
      marker.lng attraction.longitude
    end
    @hash.delete_if { |k, _v| k.empty? }

    respond_to do |format|
      format.html
      format.csv { send_data @attractions.to_csv }
    end
  end

  def new
    @attraction = Attraction.new
  end

  def edit
  end

  def create
    @attraction = Attraction.new(attraction_params)

    respond_to do |format|
      if @attraction.save
        format.html { redirect_to @attraction, notice: 'Attraction was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @attraction.update(attraction_params)
        format.html { redirect_to @attraction, notice: 'Attraction was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @attraction.destroy
    respond_to do |format|
      format.html { redirect_to attractions_url, notice: 'Attraction was successfully destroyed.' }
    end
  end

  def import
    url = params['ta_url']['url']
    Tripadvisor.import(url)

    redirect_to :root, notice: 'Import done'
  end

  def reset
    Attraction.where(visited: false).destroy_all

    redirect_to :root
  end

  private

  def set_attraction
    @attraction = Attraction.find(params[:id])
  end

  def attraction_params
    params.require(:attraction).permit(:name, :type, :link, :latitude, :longitude)
  end
end
