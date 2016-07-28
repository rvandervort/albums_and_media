require 'rails_helper'

RSpec.shared_examples "an asset fetching service for asset type" do |asset_type|
  describe "#execute!" do
    let(:asset_type_name) { asset_type.name.downcase.to_sym }
    let(:model) { asset_type.new }
    let(:options) { {media_type: asset_type, id: 1} }
    let(:service) {  described_class.new(options) }
    let(:result) { service.execute! }

    context "when the asset is found" do
      before :each do
        expect(asset_type).to receive(:find).and_return(model)
      end

      it "returns a successful service result, if the record was found" do
        expect(result.success?).to be_truthy
      end

      it "returns the photo model in the properties hash" do
        expect(result[asset_type_name]).to eq(model)
      end
    end

    context "when the asset is not found" do
      before :each do
        expect(asset_type).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      end

      it "returns an unsuccessful service result, if the record was not found" do
        expect(result.success?).to be_falsey
      end
    end
  end
end

RSpec.describe FetchMediaService do
  it_behaves_like "an asset fetching service for asset type", Photo
  it_behaves_like "an asset fetching service for asset type", Video
end


