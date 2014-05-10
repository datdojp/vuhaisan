class Product
  include Mongoid::Document

  field :name, type: String
  field :unit, type: String # kg, lit, cai, v.v...
  field :price, type: Integer
  field :quantity, type: Integer
  field :images, type: Array
  field :desc, type: String

  field :data, type: String
  field :flattened_data, type: String

  belongs_to :category, class_name: Category.name, inverse_of: :products
  has_many :order_items, class_name: OrderItem.name, inverse_of: :product

  before_destroy do |document|
    if document.images
      document.images.each do |i|
        Product.delete_image i
      end
    end
  end

  before_save do |document|
    a = get_search_data document, [
      :name, :unit_as_text, :price, :in_store_as_text, :category_as_text]
    document.data = a[0]
    document.flattened_data = a[1]
  end

  UNITS = ["kg", "hundred_g", "item", "animal_item", "bottle", "bulk", "litre"]

  def self.get_unit_text(unit)
    I18n.t "admin.#{unit}"
  end

  def unit_as_text
    Product.get_unit_text unit
  end

  def self.is_local_image?(img)
    img && /^\/uploads\/.+$/.match(img)
  end

  def self.is_remote_image?(img)
    img && /^[hH][tT][tT][pP][sS]?:\/\/.+\/.+$/.match(img)
  end

  def has_image?
    images && images.length > 0
  end

  def self.delete_image(img)
    if Product.is_local_image?(img)
      begin
        File.delete("#{Rails.root}/public#{img}")
      rescue
        # ignored
      end
    end
  end

  def in_store?
    quantity > 0
  end

  def in_store_as_text
    in_store? ? I18n.t("client.in_store") : I18n.t("client.not_in_store")
  end

  def category_as_text
    category.name
  end

  def self.general_search(keyword)
    Product.where get_search_criteria(keyword, true)
  end
end