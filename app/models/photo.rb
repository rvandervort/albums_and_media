class Photo < ActiveRecord::Base
  belongs_to :album, {inverse_of: :photos, touch: true, counter_cache: true}

  include ActiveModel::Validations

  validates :album, presence: true

  validates_with NameValidator
  validates_with FileExtensionValidator, fields: :url, extensions: ["jpg", "jpeg"]
  validates_with AlbumFullValidator
end
