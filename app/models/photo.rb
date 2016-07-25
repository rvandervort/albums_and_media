class Photo < ActiveRecord::Base
  belongs_to :album, touch: true
end
