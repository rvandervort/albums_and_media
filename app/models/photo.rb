class Photo < ActiveRecord::Base
  belongs_to :album, {touch: true, counter_cache: true}

  include ActiveModel::Validations

  validates_with FileExtensionValidator, fields: :url, extensions: ["jpg", "jpeg"]
end
