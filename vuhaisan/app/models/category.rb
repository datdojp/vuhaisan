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

  before_save do |doc|
    __sort_tag_tree_node(doc.tag_tree)

    if doc.hidden_changed?
      doc.products.each do |p|
        p.hidden = doc.hidden
        p.save
      end
    end
  end

  def __sort_tag_tree_node(node)
    if node['children'].length > 0
      node['children'].sort! { |left, right|
        is_left_leaf = left['children'].length == 0
        is_right_leaf = right['children'].length == 0
        if is_left_leaf == is_right_leaf
          left['name'] <=> right['name']
        else
          if is_left_leaf
            1
          else
            -1
          end
        end
      }
      node['children'].each do |child|
        __sort_tag_tree_node(child)
      end
    end
  end

  def self.get_client_categories_criteria
  	Category.where(hidden: false).order_by([[:no, :asc]])
  end

  def has_tag_tree?
    tag_tree && tag_tree['pcount'] > 0
  end
end