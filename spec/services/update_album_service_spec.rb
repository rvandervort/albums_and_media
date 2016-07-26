require 'rails_helper'

RSpec.describe UpdateAlbumService do
  describe '#execute' do
    let(:base_options) { {id: "1", album: {}} }

    let(:service) { described_class.new(options) }
    let(:result) { service.execute! }
    let(:model) { Album.new(id: 1123) }
    
    context "with an invalid record ID" do
      let(:options) { base_options }
      it "returns an unsuccessful result if the album does not exist" do
        expect(Album).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        expect(result).not_to be_success
        expect(result.errors[:base]).to  include("Album with id 1 not found")
      end
    end


    context "with valid album data" do
      let(:options) { base_options.merge(album: {name: "Test Album"}) }
      before :each do
        expect(Album).to receive(:find).and_return(model)
      end

      it "returns a successful result" do
        expect(result).to be_success
      end

      it "returns the album in the :album property" do
        expect(result[:album]).to eq(model)
      end
    end

    context "with invalid album data" do
      let(:options) { base_options.merge(album: {name: ""}) }

      before :each do
        expect(Album).to receive(:find).and_return(model)
      end
      
      it "returns an unsuccessful result" do
        expect(result).not_to be_success
      end

      it "returns the errors in the :errors property" do
        expect(result[:errors]).to be_a(ActiveModel::Errors)
      end
    end
  end
end
