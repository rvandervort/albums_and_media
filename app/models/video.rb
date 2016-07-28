class Video < ActiveRecord::Base
  belongs_to :album, {inverse_of: :videos, touch: true, counter_cache: true}

  include ActiveModel::Validations

  validates :album, presence: true

  validates_with NameValidator
  validates_with FileExtensionValidator, fields: :url, extensions: ["mov", "avi", "mpv"]
  validates_with AlbumFullValidator
end
