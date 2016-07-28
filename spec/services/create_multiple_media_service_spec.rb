require 'rails_helper'

RSpec.shared_examples "a multiple-record media creation service for asset type" do |asset_type, valid_extension|
  let(:asset_type_name) { asset_type.name.downcase.to_sym }
  let(:plural_asset_type_name) { asset_type_name.to_s.pluralize.to_sym }

  describe "#execute!" do
    let(:album) { Album.create(name: "Test Album", position: 1) }
    let(:params) { {:album_id => album.id, :media_type => asset_type, plural_asset_type_name => asset_list} }

    let(:service) { described_class.new(params) }
    let(:result) { service.execute! }

    context "for valid inputs", :db => true do
      let(:asset_list) {
        (1..3).map { |i| {name: i, url: "http://asset_#{i}.#{valid_extension}", album_id: album.id} }
      }

      it "creates a asset record for each entry" do
        expect { service.execute! }.to change { asset_type.count }.from(0).to(3)
      end

      it "recalculates the album's average date" do
        expect(AverageDateUpdaterService).to receive(:invoke).with(album_id: album.id)
        service.execute!
      end

      it "returns a successful ServiceResult" do
        expect(result).to be_success
      end

      it "returns the list of assets in the property list" do
        expect(result[plural_asset_type_name].size).to eq(3)

        result[plural_asset_type_name].each do |asset|
          expect(asset).to be_persisted
        end
      end
    end

    context "for invalid inputs" do
      let(:asset_list) {
        (1..3).map { |i| {name: i, url: "http://asset_#{i}.#{valid_extension}", album_id: album.id} }
      }

      it "does not create any assets unless they all have the same album id" do
        asset_list.last[:album_id] += 1
        expect { service.execute! }.not_to change { asset_type.count }
      end

      it "does not create any assets unless they all pass validation" do
        asset_list.last[:url] = "andinvalidurl#@!"

        expect { service.execute! }.not_to change { asset_type.count }
      end


      it "returns an unsuccessful ServiceResult" do
        asset_list.last[:url] = "andinvalidurl"
        asset_list[1][:name] = ""

        expect(result).not_to be_success
      end

      it "returns each set of attributes and the errors for each" do
        asset_list.last[:url] = "andinvalidurl"
        asset_list[1][:name] = ""

        asset_list_attributes = result[:attributes_and_errors]

        expect(asset_list_attributes.last[:errors][:url]).not_to be_nil
        expect(asset_list_attributes[1][:errors][:name]).not_to be_nil
      end

      it "does not update the albums average_date" do
        asset_list[1][:name] = nil
        
        expect(AverageDateUpdaterService).not_to receive(:invoke)
        service.execute!
      end
    end
  end
end

RSpec.describe CreateMultipleMediaService do
  it_behaves_like "a multiple-record media creation service for asset type", Photo, 'jpg'
  it_behaves_like "a multiple-record media creation service for asset type", Video, 'avi'
end
