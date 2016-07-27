require 'rails_helper'

RSpec.describe UpdateAlbumService do
  describe '#execute' do
    let(:base_options) { {id: "1", album: {}} }

    let(:service) { described_class.new(options) }
    let(:result) { service.execute! }
    let(:model) { Album.new(id: 1123) }
    
    context "with an invalid record ID" do
      let(:options) { base_options }
      it "returns an unsuccessful result if the album does not exist" do
        expect(Album).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        expect(result).not_to be_success
        expect(result.errors[:base]).to  include("Album with id 1 not found")
      end
    end


    context "with valid album data" do
      let(:options) { base_options.merge(album: {name: "Test Album"}) }
      before :each do
        expect(Album).to receive(:find).and_return(model)
        expect(model).to receive(:update).and_return(true)
      end

      it "returns a successful result" do
        expect(result).to be_success
      end

      it "returns the album in the :album property" do
        expect(result[:album]).to eq(model)
      end
    end

    context "with invalid album data" do
      let(:options) { base_options.merge(album: {name: ""}) }

      before :each do
        expect(Album).to receive(:find).and_return(model)
        expect(model).to receive(:update).and_return(false)
      end
      
      it "returns an unsuccessful result" do
        expect(result).not_to be_success
      end

      it "returns the errors in the :errors property" do
        expect(result[:errors]).to be_a(ActiveModel::Errors)
      end
    end


    describe "positioning logic", :db => true do
      let(:options) { base_options }

      it "does not shift other albums if there is no update to be made to the position" do
        albums = 5.times.map { |i| Album.create(name: "Album #{i}", position: i) }

        options[:album].delete(:position)
        expect(result).to be_success

        albums.each_with_index do |album, index|
          expect(album.reload.position).to eq(index)
        end
      end

      it "does not shift other albums if the positions have not changed" do
        albums = 5.times.map { |i| Album.create(name: "Album #{i}", position: i) }

        options[:id] = albums.first.id
        options[:album][:position] = albums.first.position

        expect(result).to be_success

        albums.each_with_index do |album, index|
          expect(album.reload.position).to eq(index)
        end
      end

      it "shifts other albums to the right, if the new position is lower than the old position" do
        albums = 5.times.map { |i| Album.create(name: "Album #{i}", position: i) }

        # Move position 3 to position 1
        options[:album][:position] = 1
        options[:id] = albums[3].id

        expect(result).to be_success
        expect(albums[0].reload.position).to eq(0)
        expect(albums[1].reload.position).to eq(2)
        expect(albums[2].reload.position).to eq(3)
        expect(albums[3].reload.position).to eq(1)
        expect(albums[4].reload.position).to eq(4)
      end

      it "shifts other albums to the left, if the new position is greater than the old position" do
        albums = 5.times.map { |i| Album.create(name: "Album #{i}", position: i) }

        # Move position 1 to position 3
        options[:album][:position] = 3
        options[:id] = albums[1].id

        expect(result).to be_success
        expect(albums[0].reload.position).to eq(0)
        expect(albums[1].reload.position).to eq(3)
        expect(albums[2].reload.position).to eq(1)
        expect(albums[3].reload.position).to eq(2)
        expect(albums[4].reload.position).to eq(4)
      end
    end
  end
end
