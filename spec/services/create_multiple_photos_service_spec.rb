require 'rails_helper'

RSpec.describe CreateMultiplePhotosService do
  describe "#execute!" do
    let(:album) { Album.create(name: "Test Album", position: 1) }
    let(:params) { {album_id: album.id, photos: photo_list} }

    let(:service) { described_class.new(params) }
    let(:result) { service.execute! }

    context "for valid inputs", :db => true do
      let(:photo_list) {[
        {name: "1", url: "http://photo_1.jpg", album_id: album.id},
        {name: "2", url: "http://photo_2.jpg", album_id: album.id},
        {name: "3", url: "http://photo_3.jpg", album_id: album.id},
      ]}

      it "creates a photo record for each entry" do
        expect { service.execute! }.to change { Photo.count }.from(0).to(3)
      end

      it "recalculates the album's average date" do
        expect(AverageDateUpdaterService).to receive(:invoke).with(album_id: album.id)
        service.execute!
      end

      it "returns a successful ServiceResult" do
        expect(result).to be_success
      end

      it "returns the list of photos in the :photos property" do
        result[:photos].each do |photo|
          expect(photo).to be_persisted
        end
      end
    end

    context "for invalid inputs" do
      let(:photo_list) {[
        {name: "1", url: "http://photo_1.jpg", album_id: album.id},
        {name: "2", url: "http://photo_2.jpg", album_id: album.id},
        {name: "3", url: "http://photo_3.jpg", album_id: album.id},
      ]}

      it "does not create any photos unless they all have the same album id" do
        photo_list.last[:album_id] += 1
        expect { service.execute! }.not_to change { Photo.count }
      end

      it "does not create any photos unless they all pass validation" do
        photo_list.last[:url] = "andinvalidurl"

        expect { service.execute! }.not_to change { Photo.count }
      end


      it "returns an unsuccessful ServiceResult" do
        photo_list.last[:url] = "andinvalidurl"
        photo_list[1][:name] = ""

        expect(result).not_to be_success
      end

      it "returns each set of attributes and the errors for each" do
        photo_list.last[:url] = "andinvalidurl"
        photo_list[1][:name] = ""

        photo_list_attributes = result[:attributes_and_errors]

        expect(photo_list_attributes.last[:errors][:url]).not_to be_nil
        expect(photo_list_attributes[1][:errors][:name]).not_to be_nil
      end

      it "does not update the albums average_date" do
        photo_list[1][:name] = nil

        expect(AverageDateUpdaterService).not_to receive(:invoke)
        service.execute!
      end
    end
  end
end
