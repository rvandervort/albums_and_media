require 'rails_helper'

RSpec.describe DestroyPhotoService, :db => true do
  let(:album) { Album.create(name: "Test Album", position: 1) }
  let(:photo) { Photo.create(url: "http://test.jpg", album_id: album.id) }

  let(:options) { {id: photo.id } }
  let(:service) { described_class.new(options) }
  let(:result) { service.execute! }

  describe '#execute!', :db => true do
    context "when the photo exists" do
      it "returns a successful result" do
        expect(result).to be_success
      end

      it "destroys the photo" do
        service.execute!
        expect { photo.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "recalculates the containing album's average_date" do
        expect(AverageDateUpdaterService).to receive(:invoke).with({album_id: album.id}).exactly(:once)
        service.execute!
      end
    end


    context "when the photo doesn't exist" do
      it "returns an unsuccessful result" do
        options[:id] = -1
        expect(result).not_to be_success
      end
    end
  end
end
