class Album < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :photos, inverse_of: :album, dependent: :destroy
  has_many :videos, inverse_of: :album, dependent: :destroy

  validates_with NameValidator, PositionValidator

  def self.max_media
    60
  end

  def full?
    (photos_count + videos_count) >= self.class.max_media
  end
end
