class Album < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :photos, dependent: :destroy

  validates_with NameValidator, PositionValidator

  def self.max_photos
    60
  end

  def full?
    photos_count >= self.class.max_photos
  end
end
