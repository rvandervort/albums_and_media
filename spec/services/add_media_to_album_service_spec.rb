require 'rails_helper'

RSpec.shared_examples "a service to add media to an album for asset type" do |asset_type, valid_extension|
  describe '#execute!', :db => true do
    let(:asset_type_name) { asset_type.name.downcase.to_sym }
    let(:plural_asset_type_name) { asset_type_name.to_s.pluralize.to_sym }
    let(:model) { asset_type.create(name: "Asset Type", url: "http://www.whaterever.com/file.#{valid_extension}") }
    let(:album) { Album.create(name: "Test Album", position: 1) }
    let(:options) { {album_id: album.id, media_type: plural_asset_type_name.to_s, media_type_id: model.id} }
    
    let(:service) { described_class.new(options) }
    let(:result) { service.execute! }

    context "for a valid asset and valid album" do

      it "adds the asset to the album"  do
        expect { service.execute! }.to change { ContentList.count }.by(1)
      end

      it "recalculates the album's average date" do
        expect(AverageDateUpdaterService).to receive(:invoke).with(album_id: album.id)
        service.execute!
      end

      it "returns a successful ServiceResult" do
        expect(result).to be_success
      end

      it "returns the ContentList instance in the properties" do
        expect(result[:content_list]).to be_a(ContentList)
      end
      
    end

    context "for invalid data" do
      it "does not add the asset to the album if the album doesn't exist" do
        options[:album_id] = -1
        expect { service.execute! }.not_to change { ContentList.count }
      end

      it "does not add the asset to the album if the asset doesn't exist" do 
        options[:media_type_id] = -1
        expect { service.execute! }.not_to change { ContentList.count }
      end

      it "does not add the asset to the album if the album is full" do
        expect_any_instance_of(Album).to receive(:full?).and_return(true)
        service.execute!
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


RSpec.describe AddMediaToAlbumService do
  it_behaves_like "a service to add media to an album for asset type", Photo, 'jpg'
  it_behaves_like "a service to add media to an album for asset type", Video, 'avi'
end
