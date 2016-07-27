require 'rails_helper'

RSpec.describe PhotosController, type: :controller do
  describe '#index' do
    let(:base_request_attributes) { {format: 'json'} }

    context "for invalid page numbers" do
      ["-1", "abc", "0"].each do |page_number|
        it "returns 422 status code when page number is '#{page_number}'" do
          get :index, base_request_attributes.merge('page' => page_number)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "for valid page numbers" do
      let(:request_attributes) { base_request_attributes.merge(page: 2) }
      let(:photos) { double() }

      let(:successful_result) {
        ServiceResult.new.tap do |result|
          result.success = true
          result[:photos] = photos
        end
      }

      before :each do
        expect(GetPhotosService).to receive(:invoke).and_return(successful_result)
      end

      it "returns 200 ok" do
        get :index, request_attributes
        expect(response).to have_http_status(:ok)
      end

      it "sets provides the resulting list of photos" do
        get :index, request_attributes
        expect(assigns(:photos)).to eq(photos)
      end
    end
  end
end
