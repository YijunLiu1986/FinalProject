class Product < ApplicationRecord
  mount_uploader :image, ImageUploader
  self.per_page = 7

  # some validate
  validates :name, presence: true
  validates :price, :stock, numericality: true

  # Initialize filterific to this model
  filterrific(
      default_filter_params: { sorted_by: 'created_at_desc' },
      available_filters: [
          :sorted_by,
          :search_query,
          :with_category_id
      ]
  )

  # Association
  belongs_to :category
  has_many :order_items

  # The search function
  scope :search_query, lambda { |query|
    return nil  if query.blank?

    terms = query.downcase.split(/\s+/)

    terms = terms.map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    num_or_conditions = 1

    where(
        terms.map {
          or_clauses = [
              "LOWER(products.name) LIKE ?"
          ].join(' OR ')
          "(#{ or_clauses })"
        }.join(' AND '),
        *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }
  # Sorted by foreign key
  scope :with_category_id, lambda { |category_ids|
    where(category_id: [*category_ids])
  }

  # Sorted by column
  scope :sorted_by, lambda { |sort_option|

       direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'

       case sort_option.to_s
         when /^created_at_/
           order("products.created_at #{ direction }")

         when /^name_/
           order("LOWER(products.name) #{direction}")

         when /^price_/
           order("products.price #{ direction }")
         else
           raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
       end
  }

  def self.options_for_sorted_by
    [
        ['Name (a-z)', 'name_asc'],
        ['Newest (newest first)', 'created_at_desc'],
        ['Price', 'price_asc']
    ]
  end
end
