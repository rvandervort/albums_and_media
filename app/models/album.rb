class Album < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :photos, dependent: :destroy

  validates_with NameValidator
end
