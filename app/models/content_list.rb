class ContentList < ActiveRecord::Base
  belongs_to :album
  belongs_to :asset, polymorphic: true

  validates :album, presence: true
  validates :asset, presence: true

  validates_with AlbumFullValidator


  after_create :increment_counter
  after_destroy :decrement_counter

  private

  def counter_field
    "#{asset_type.downcase.pluralize}_count"
  end

  def increment_counter
    Album.increment_counter(counter_field, album.id)
  end

  def decrement_counter
    Album.decrement_counter(counter_field, album.id)
  end
end
