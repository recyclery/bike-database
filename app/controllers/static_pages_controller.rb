class StaticPagesController < ApplicationController
  before_action :authenticate_user!
  def home; end

  def bikes_by_location
    @sales_floor_bikes = Bike.where(location: Bike::SALES_FLOOR, purpose: Bike::SALE)
    @paulina_basement_bikes = Bike.where(location: Bike::PAULINA_BASEMENT, purpose: Bike::SALE)
    @seward_basement_bikes = Bike.where(location: Bike::SEWARD_BASEMENT, purpose: Bike::SALE)
  end

  def sale_bikes
    @sale_bikes = Bike.where(purpose: Bike::SALE, date_sold: nil)
    respond_to do |format|
      format.html
      format.csv { send_data @sale_bikes.to_csv_for_reconciliation, filename: "sale_bikes-#{Date.today}.csv" }
    end
  end
end
