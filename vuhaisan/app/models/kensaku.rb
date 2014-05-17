class Kensaku
  include Mongoid::Document
  include Mongoid::Timestamps

  field :keyword, type: String
  field :n_searches, type: Integer
  field :last_n_results, type: Integer
end