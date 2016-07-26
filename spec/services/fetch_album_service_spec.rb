require 'rails_helper'

RSpec.describe FetchAlbumService do
  describe "#execute!" do
    let(:model) { Album.new }
    let(:options) { {id: 1} }
    let(:service) {  described_class.new(options) }
    let(:result) { service.execute! }

    context "when the album is found" do
      before :each do
        expect(Album).to receive(:find).and_return(model)
      end
      
      it "returns a successful service result, if the record was found" do
        expect(result.success?).to be_truthy
      end

      it "returns the album model in the properties hash" do
        expect(result[:album]).to eq(model)
      end
    end

    context "when the album is not found" do
      before :each do
        expect(Album).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      end

      it "returns an unsuccessful service result, if the record was not found" do
        expect(result.success?).to be_falsey
      end
    end
  end
end
