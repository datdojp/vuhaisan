class Product
  include Mongoid::Document

  field :name, type: String
  field :unit, type: String # kg, lit, cai, v.v...
  field :price, type: Integer
  field :quantity, type: Integer
  field :image, type: String
  field :desc, type: String

  field :data, type: String
  field :flattened_data, type: String

  belongs_to :category, class_name: Category.name, inverse_of: :products
  has_many :order_items, class_name: OrderItem.name, inverse_of: :product

  before_destroy :delete_image

  before_save do |document|
    a = get_search_data document, [
      :name, :unit_as_text, :price, :in_store_as_text, :category_as_text]
    document.data = a[0]
    document.flattened_data = a[1]
  end

  UNITS = ["kg", "hundred_g", "item", "animal_item"]

  def self.get_unit_text(unit)
    I18n.t "admin.#{unit}"
  end

  def unit_as_text
    Product.get_unit_text unit
  end

  def get_image_url
    "/uploads/#{image}"
  end

  def delete_image
    if image
      begin
        File.delete("#{Rails.root}/public/uploads/#{image}")
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
    Product.where get_search_criteria(keyword)
  end
end