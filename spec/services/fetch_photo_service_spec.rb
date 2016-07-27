require 'rails_helper'

RSpec.describe FetchPhotoService do
  describe "#execute!" do
    let(:model) { Photo.new }
    let(:options) { {id: 1} }
    let(:service) {  described_class.new(options) }
    let(:result) { service.execute! }

    context "when the photo is found" do
      before :each do
        expect(Photo).to receive(:find).and_return(model)
      end

      it "returns a successful service result, if the record was found" do
        expect(result.success?).to be_truthy
      end

      it "returns the photo model in the properties hash" do
        expect(result[:photo]).to eq(model)
      end
    end

    context "when the photo is not found" do
      before :each do
        expect(Photo).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      end

      it "returns an unsuccessful service result, if the record was not found" do
        expect(result.success?).to be_falsey
      end
    end
  end
end
