class Category
  include Mongoid::Document

  field :name, type: String
  field :no, type: Integer
  field :hidden, type: Boolean, default: false
  field :tag_tree, type: Hash, default: {
    'name' => "",
    'children' => [],
    'pids' => [],
    'pcount' => 0
  }

  has_many :products, class_name: Product.name, inverse_of: :category

  validates :name, uniqueness: true

  before_create do |document|
  	document.no = Category.count
  end

  def self.get_client_categories_criteria
  	Category.where(hidden: false).order_by([[:no, :asc]])
  end

  def has_tag_tree?
    tag_tree && tag_tree['pcount'] > 0
  end
end