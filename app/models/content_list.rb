class ContentList < ActiveRecord::Base
  belongs_to :album
  belongs_to :asset, polymorphic: true

  validates :album, presence: true
  validates :asset, presence: true

  validates_with AlbumFullValidator
end
