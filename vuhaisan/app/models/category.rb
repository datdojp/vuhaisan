class Category
  include Mongoid::Document

  field :name, type: String

  has_many :products, class_name: Product.name, inverse_of: :category

  validates :name, uniqueness: true
end