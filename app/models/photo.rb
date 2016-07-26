class Photo < ActiveRecord::Base
  belongs_to :album, {touch: true, counter_cache: true}
end
