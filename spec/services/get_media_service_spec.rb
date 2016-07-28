require 'rails_helper'

RSpec.shared_examples "a media listing service for asset type" do |asset_type, valid_extension|

  describe '#execute!', :db => true do
    let(:asset_type_name) { asset_type.name.downcase.to_sym }
    let(:plural_asset_type_name) { "#{asset_type_name.to_s.pluralize}".to_sym }

    let(:basic_options) { {media_type: asset_type} }
    let(:service) { described_class.new(options) }
    let(:result) { service.execute! }
    let(:album) { Album.create(name: 'Test Album', position: 1) }

    let(:assets) {
      20.times.map do |i|
        album.send(plural_asset_type_name) << asset_type.create(name: asset_type.name, url: "http://,#{valid_extension}")
      end
    }

    before :each do
      assets.sort
    end

    context 'when listing for an album' do
      let(:options) { basic_options.merge(album_id: album.id) }

      it "does not paginate the results" do
        expect(result[plural_asset_type_name].count).to eq(20)
      end
    end

    context 'when listing without an album reference' do
      let(:options) { basic_options }
      it 'paginates the results' do
        # Don't use #count, returns 'wrong' result
        expect(result[plural_asset_type_name].size).to be < 20
      end
    end
  end
end

RSpec.describe GetMediaService do
  it_behaves_like "a media listing service for asset type", Photo, "jpg"
  it_behaves_like "a media listing service for asset type", Video, "avi"
end
