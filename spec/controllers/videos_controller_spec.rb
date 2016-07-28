require 'rails_helper'

RSpec.describe VideosController, type: :controller do
  it_behaves_like "A media controller for asset type", Video, "avi"
end
