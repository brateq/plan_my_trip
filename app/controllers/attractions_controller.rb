class AttractionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_attraction, only: %i[show edit update destroy must_see visited]

  def index
    @q = Attraction.includes(:statuses)
                    .where(statuses: { user_id: [current_user.id, nil], wanna_go: [nil, 3]})
                    .ransack(params[:q])
    @attractions = @q.result(distinct: true)
    @attractions = AttractionDecorator.decorate(@attractions)

    respond_to do |format|
      format.html
      format.json
      format.csv { send_data @attractions.to_csv }
    end
  end

  def list
    params[:type] = 'continent' if params[:type].nil?
    params[:name] = 'Europa' if params[:name].nil?
    attractions = Attraction.where(params[:type] => params[:name])

    @attractions = AttractionDecorator.decorate(attractions)
  end

  def new
    @attraction = Attraction.new
  end

  def edit; end

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
        format.html { redirect_to list_attractions_path, notice: 'Attraction was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def download_locations
    @attractions = Attraction.ransack(params[:q]).result(distinct: true)
    @attractions.each(&:download_location)

    redirect_to :root
  end

  def must_see
    current_user.statuses.create(attraction: @attraction, wanna_go: 3)

    redirect_back(fallback_location: root_path)
  end

  def visited
    current_user.statuses.create(attraction: @attraction, visited: true)

    redirect_back(fallback_location: root_path)
  end

  def destroy
    current_user.statuses.create(attraction: @attraction, wanna_go: 0)

    redirect_back(fallback_location: root_path)
  end

  def import
    url = params['ta_url']['url']
    Tripadvisor.delay.import(url)

    redirect_to :root, notice: 'Import started'
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
