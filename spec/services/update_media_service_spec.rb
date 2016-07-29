require 'rails_helper'

RSpec.shared_examples "a media update service for asset type" do |asset_type, valid_file_extension|
  describe '#execute', :db => true do

    let(:asset_type_name) { asset_type.name.downcase.to_sym }
    
    let(:model) { asset_type.create(name: asset_type.name, url: "https://sdfsdf.#{valid_file_extension}") } 

    let(:base_options) { {:media_class => asset_type, :id => model.id, asset_type_name => {}} }

    let(:service) { described_class.new(options) }
    let(:result) { service.execute! }

    context "with an invalid record ID" do
      let(:options) { base_options }
      it "returns an unsuccessful result if the asset does not exist" do
        expect(asset_type).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        expect(result).not_to be_success
        expect(result.errors[:base]).to  include("#{asset_type.name} with id 1 not found")
      end
    end


    context "with valid asset data" do
      let(:options) { base_options.merge(asset_type_name => {name: "Test Asset"}) }

      it "returns a successful result" do
        expect(result).to be_success
      end

      it "returns the asset in the properties" do
        expect(result[asset_type_name]).to eq(model)
      end

    end

    context "with invalid data" do
      let(:options) { base_options.merge(asset_type_name => {url: "sdfsdf"}) }

      it "returns an unsuccessful result" do
        expect(result).not_to be_success
      end

      it "returns the errors in the :errors property" do
        expect(result[:errors]).to be_a(ActiveModel::Errors)
      end
    end
  end
end

RSpec.describe UpdateMediaService do
  it_behaves_like "a media update service for asset type", Photo, "jpg"
  it_behaves_like "a media update service for asset type", Video, "avi"
end

