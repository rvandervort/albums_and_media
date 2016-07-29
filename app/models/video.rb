class Video < ActiveRecord::Base
  has_many :content_list, as: :asset, dependent: :destroy
  has_many :albums, through: :content_list

  include ActiveModel::Validations

  validates_with NameValidator
  validates_with FileExtensionValidator, fields: :url, extensions: ["mov", "avi", "mpv"]
end
