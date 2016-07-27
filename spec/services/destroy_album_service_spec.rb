require 'rails_helper'

RSpec.describe DestroyAlbumService do
  let(:options) { { } }
  let(:service) { described_class.new(options) }
  let(:result) { service.execute! }

  describe '#execute!', :db => true do
    it "returns a successful result when the album record was destroyed" do
      album = Album.create(name: "Test Album", position: 1)

      options[:id] = album.id

      expect(result).to be_success
    end

    it "returns an unsuccessful result, if album doesn't exist" do
      options[:id] = -1
      expect(result).not_to be_success
    end


    describe "position shifting" do
      it "shifts albums with higher positions" do
        albums = 5.times.map { |i| Album.create(name: "Album #{i}", position: i) }

        # Delete the first album
        options[:id] = albums[0].id

        expect(result).to be_success

        expect(albums[1].reload.position).to eq(0)
        expect(albums[2].reload.position).to eq(1)
        expect(albums[3].reload.position).to eq(2)
        expect(albums[4].reload.position).to eq(3)
      end
    end
  end
end
