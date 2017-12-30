class Bike < ActiveRecord::Base
  FREECYCLERY = "Freecyclery"
  SALE = "Sale"

  SEWARD_BASEMENT = "Seward Basement"
  PAULINA_BASEMENT = "Paulina Basement"
  SALES_FLOOR = "Sales Floor"
  SOLD = "Sold"

  LOCATIONS = [SEWARD_BASEMENT, PAULINA_BASEMENT, SALES_FLOOR, SOLD]
  BIKE_TYPES = ["BMX", "Cruiser", "Hybrid", "Kids", "Mountain", "Road", "Touring", "Track", "Utility", "Youth"]

  validates :log_number, presence: true
  validates :brand, presence: true
  validates :model, presence: true
  validates :bike_type, presence: true
  validates :color, presence: true
  validates :serial_number, presence: true
  validates :location, inclusion: { in: LOCATIONS, allow_blank: true }
  validates_numericality_of :time_spent, greater_than_or_equal_to: 0, allow_nil: true
  has_one :client


  def sold?
    date_sold.present?
  end

  def mark_sold
    update_attributes(date_sold: Time.now, location: SOLD)
  end

  def name
    (self.color + " " + self.brand + ' ' + self.model + " (" + self.log_number.to_s + ")").titleize
  end

  def client
    Client.find_by bike_id: self.id
  end

  def ready_for_pickup?
    self.client && !client.application_voided && self.date_sold.nil?
  end

  def self.available_for_freecyclery
    assigned_bikes = Client
      .where("application_voided != ? or application_voided is null", true)
      .includes(:bike)
      .select{|c| !c.bike_id.nil?}.map(&:bike)
    all_freecyclery_bikes = Bike.where(purpose: FREECYCLERY)
                                .order(log_number: :desc)
    all_freecyclery_bikes - assigned_bikes
  end

  def post_to_bike_index
    return true if self.bike_index_id.present?
    BikeIndexLogger.perform_async(self.id)
  end
end
