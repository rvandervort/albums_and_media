require 'rails_helper'

RSpec.shared_examples "a media destruction service for asset type" do |asset_type, valid_extension|

  let(:album) { Album.create(name: "Test Album", position: 1) }
  let(:model) { asset_type.create(name: asset_type.name, url: "http://test#{valid_extension}") }
  let(:plural_asset_type_name) { asset_type.name.downcase.pluralize.to_sym }

  let(:options) { {media_type: asset_type, id: model.id } }
  let(:service) { described_class.new(options) }
  let(:result) { service.execute! }

  describe '#execute!', :db => true do
    context "when the asset exists" do
      before :each do
        ContentList.create(album: album, asset: model)
      end
      it "returns a successful result" do
        expect(result).to be_success
      end

      it "destroys the asset" do
        service.execute!
        expect { model.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "recalculates the containing album's average_date" do
        expect(AverageDateUpdaterService).to receive(:invoke).with({album_id: album.id}).exactly(:once)
        service.execute!
      end
    end


    context "when the asset doesn't exist" do
      it "returns an unsuccessful result" do
        options[:id] = -1
        expect(result).not_to be_success
      end
    end
  end
end

RSpec.describe DestroyMediaService do
  it_behaves_like "a media destruction service for asset type", Photo, 'jpg'
  it_behaves_like "a media destruction service for asset type", Video, 'avi'
end
