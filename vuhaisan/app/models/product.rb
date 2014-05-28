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

  field :custom_fields, type: Hash, default: {}
  field :tags, type: Array, default: []

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

    # prepare category 's tag
    tag_tree = document.category.tag_tree
    pid = document.id.to_s
    __iterate_category_tags(
        tag_tree,
        [],
        proc do |node|
          node[:pids] ||= []
          node[:pids].delete(pid)
        end
      )
    document.tags.each do |tag|
      tokens = tag.split(",")
      cur = tag_tree
      tokens.each_with_index do |t, i|
        t.strip!
        next if t.length == 0
        if i < tokens.length-1
          cur[:children].each do |child|
            if child[:name] == t
              cur = child
              next
            else
              
            end
          end
        else

        end
      end
    end
  end

  def __iterate_category_tags(node, callback)
    callback.call(node)
    if node[:children] && node[:children].length > 0
      node[:children].each do |child|
        __iterate_category_tags(child, callback)
      end
    end
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