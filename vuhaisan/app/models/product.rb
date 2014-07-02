class Product
  include Mongoid::Document
  include Mongoid::Timestamps

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

  field :hidden, type: Boolean, default: false

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

    if document.category_id_changed?
      document.hidden = document.category.hidden
    end

    # BUILD CATEGORY 'S TAG TREE
    pid = document.id.to_s
    if document.persisted?
      if document.category_id_changed?
        origin_product = Product.where(id: pid).only(:category_id, :tags).first
        if  origin_product.tags.length > 0
          old_category = origin_product.category
          __delete_pid_from_category_tag_tree(old_category.tag_tree, pid)
          __recalculate_category_tag_tree_pcount(old_category.tag_tree)
          __purge_category_tag_tree(old_category.tag_tree)
          old_category.save
        end
        if document.tags.length > 0
          new_category = document.category
          __add_tags_to_category_tag_tree(new_category.tag_tree, document.tags, pid)
          __recalculate_category_tag_tree_pcount(new_category.tag_tree)
          new_category.save
        end
      elsif document.tags_changed?
        category = document.category
        __delete_pid_from_category_tag_tree(category.tag_tree, pid)
        __add_tags_to_category_tag_tree(category.tag_tree, document.tags, pid)
        __recalculate_category_tag_tree_pcount(category.tag_tree)
        __purge_category_tag_tree(category.tag_tree)
        category.save
      end
    else
      if document.tags.length > 0
        category = document.category
        __add_tags_to_category_tag_tree(category.tag_tree, document.tags, pid)
        __recalculate_category_tag_tree_pcount(category.tag_tree)
        category.save
      end
    end
  end

  def __purge_category_tag_tree(node)
    node['children'].each do |child|
      if child['pcount'] == 0
        node['children'].delete(child)
      else
        __purge_category_tag_tree(child)
      end
    end
  end

  def __delete_pid_from_category_tag_tree(node, pid)
    node['pids'].delete(pid)
    node['children'].each do |child|
      __delete_pid_from_category_tag_tree(child, pid)
    end
  end

  def __recalculate_category_tag_tree_pcount(node)
    pcount = node['pids'].length
    node['children'].each do |child|
      pcount += __recalculate_category_tag_tree_pcount(child)
    end
    node['pcount'] = pcount
    pcount
  end

  def __add_tags_to_category_tag_tree(tag_tree, tags, pid)
    tags.each do |tag|
      tokens = tag.split(",")
      cur = tag_tree
      tokens.each_with_index do |t, i|
        t.strip!
        next if !t || t.length == 0

        # find child node whose name equals to token
        found = false
        cur['children'].each do |child|
          if child['name'] == t
            cur = child
            found = true
            break
          end
        end
        if !found
          new_node = {
            'name' => t,
            'children' => [],
            'pids' => [],
            'pcount' => 0
          }
          cur['children'] << new_node
          cur = new_node
        end

        # if token is last one, add pid
        if i == tokens.length - 1
          cur['pids'] << pid
        end
      end
    end
  end

  UNITS = ["kg", "hundred_g", "item", "animal_item", "bottle", "bulk", "litre", "set"]

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