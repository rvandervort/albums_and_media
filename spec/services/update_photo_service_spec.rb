require 'rails_helper'

RSpec.describe UpdatePhotoService do
  describe '#execute', :db => true do
    let(:model) { Photo.create(name: "Photo", url: "https://sdfsdf.jpg", album_id: old_album.id) }
    let(:old_album) { Album.create(name: "Test Album", position: 1) }
    let(:new_album) { Album.create(name: "Test Album 2", position: 2) }

    let(:base_options) { {id: model.id, photo: {}} }

    let(:service) { described_class.new(options) }
    let(:result) { service.execute! }

    context "with an invalid record ID" do
      let(:options) { base_options }
      it "returns an unsuccessful result if the photo does not exist" do
        expect(Photo).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        expect(result).not_to be_success
        expect(result.errors[:base]).to  include("Photo with id 1 not found")
      end
    end


    context "with valid photo data" do
      let(:options) { base_options.merge(photo: {name: "Test Photo", album_id: new_album.id}) }

      it "returns a successful result" do
        expect(result).to be_success
      end

      it "returns the photo in the :photo property" do
        expect(result[:photo]).to eq(model)
      end

      context "with album changes" do
        it "recalculates the old album's average_date" do
          expect(AverageDateUpdaterService).to receive(:invoke).exactly(:once).with(id: old_album.id)
          expect(AverageDateUpdaterService).to receive(:invoke).exactly(:once).with(id: new_album.id)

          service.execute!

          expect(model.reload.album_id).to eq(new_album.id)
        end
      end
    end

    context "with invalid photo data" do
      let(:options) { base_options.merge(photo: {url: "sdfsdf"}) }

      it "returns an unsuccessful result" do
        expect(result).not_to be_success
      end

      it "returns the errors in the :errors property" do
        expect(result[:errors]).to be_a(ActiveModel::Errors)
      end
    end
  end
end
