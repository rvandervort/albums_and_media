require 'rails_helper'

describe GetPhotosService do
  describe '#execute!', :db => true do
    let(:basic_options) { {} }
    let(:service) { described_class.new(options) }
    let(:result) { service.execute! }
    let(:album) { Album.create(name: 'Test Album', position: 1) }

    let(:photos) {
      20.times.map do |i|
        album.photos << Photo.create(name: "Photo", url: "http://,jpg")
      end
    }

    before :each do
      photos.sort
    end

    context 'when listing for an album' do
      let(:options) { basic_options.merge(album_id: album.id) }

      it "does not paginate the results" do
        expect(result[:photos].count).to eq(20)
      end
    end

    context 'when listing without an album reference' do
      let(:options) { basic_options }
      it 'paginates the results' do
        # Don't use #count, returns 'wrong' result
        expect(result[:photos].size).to be < 20
      end
    end
  end
end
