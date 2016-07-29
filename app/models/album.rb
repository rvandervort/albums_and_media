class Album < ActiveRecord::Base
  has_many :content_list, dependent: :destroy
  has_many :photos, through: :content_list, source: :asset, source_type: "Photo"
  has_many :videos, through: :content_list, source: :asset, source_type: "Video"

  include ActiveModel::Validations

  validates_with NameValidator, PositionValidator

  def self.max_media
    60
  end

  def full?
    content_list.count >= self.class.max_media
  end

  def will_be_full_by_adding?(media_count)
    (content_list.count + media_count) >= self.class.max_media
  end
end
