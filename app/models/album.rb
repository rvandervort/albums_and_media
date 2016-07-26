class Album < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :photos

  validates_with NameValidator
end
