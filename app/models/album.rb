class Album < ActiveRecord::Base
  has_many :content_list, dependent: :destroy
  has_many :photos, through: :content_list, source: :asset, source_type: "Photo"
  has_many :videos, through: :content_list, source: :asset, source_type: "Video"

  include ActiveModel::Validations

  validates_with NameValidator, PositionValidator

  def self.max_media
    60
  end

  def current_media_count
    photos_count + videos_count
  end

  def full?
    current_media_count >= self.class.max_media
  end

  def will_be_full_by_adding?(new_media_count)
    (current_media_count + new_media_count) >= self.class.max_media
  end
end
