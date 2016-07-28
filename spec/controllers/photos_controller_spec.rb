require 'rails_helper'

RSpec.describe PhotosController, type: :controller do
  it_behaves_like "A media controller for asset type", Photo, "jpg"
end
