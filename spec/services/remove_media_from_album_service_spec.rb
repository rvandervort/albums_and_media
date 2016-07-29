require 'rails_helper'

RSpec.shared_examples "a service to remove media from an album for asset type" do |asset_type, valid_extension|
  describe '#execute!', :db => true do
    let(:asset_type_name) { asset_type.name.downcase.to_sym }
    let(:plural_asset_type_name) { asset_type_name.to_s.pluralize.to_sym }
    let(:model) { asset_type.create(name: "Asset Type", url: "http://www.whaterever.com/file.#{valid_extension}") }
    let(:album) { Album.create(name: "Test Album", position: 1) }
    let(:album2) { Album.create(name: "Test Album", position: 1) }
    let(:options) { {album_id: album.id, media_type: plural_asset_type_name.to_s, media_type_id: model.id} }
    
    let(:service) { described_class.new(options) }
    let(:result) { service.execute! }

    before :each do
      ContentList.create(album_id: album.id, asset: model)
    end

    context "for a valid asset and valid album" do
      it "removes the asset from the album"  do
        expect { service.execute! }.to change { ContentList.count }.from(1).to(0)
      end

      it "recalculates the album's average date" do
        expect(AverageDateUpdaterService).to receive(:invoke).with(album_id: album.id)
        service.execute!
      end

      it "returns a successful ServiceResult" do
        expect(result).to be_success
      end

      it "destroys the asset if it doesn't belong in any more albums" do
        service.execute!
        expect { model.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "does not destroy the assets if it belongs to more than one album" do
        ContentList.create(album: album, asset: model)
        service.execute!
        expect { model.reload }.not_to raise_error
      end
    end

    context "for invalid data" do
      it "does not remove the asset from the album if the album doesn't exist" do
        options[:album_id] = -1
        expect { service.execute! }.not_to change { ContentList.count }
      end

      it "does not remove the asset from the album if the asset doesn't exist" do 
        options[:media_type_id] = -1
        expect { service.execute! }.not_to change { ContentList.count }
      end

      it "returns an unsuccessful ServiceResult" do
        options[:media_type_id] = -1
        expect(result).not_to be_success
      end

      it "returns the errors in the :errors property" do
        options[:media_type_id] = -1
        expect(result[:errors]).not_to be_nil
      end
    end
  end
end


RSpec.describe RemoveMediaFromAlbumService do
  it_behaves_like "a service to remove media from an album for asset type", Photo, 'jpg'
  it_behaves_like "a service to remove media from an album for asset type", Video, 'avi'
end
