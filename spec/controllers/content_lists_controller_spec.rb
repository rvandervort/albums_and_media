require 'rails_helper'

RSpec.describe ContentListsController do
  describe '#create' do
    let(:request_attributes) { {format: 'json', album_id: 5678, media_type: "photos", media_type_id: "1"} }
    let(:content_list) { ContentList.new }
    
    before :each do
      expect(AddMediaToAlbumService).to receive(:invoke).and_return(service_result)
    end
    
    context 'for a valid request, with valid data' do
      let(:service_result) do
        ServiceResult.new.tap do |result|
          result.success = true
          result[:content_list] = content_list
        end
      end

      it "returns status 201 created" do
        post :create, request_attributes 
        expect(response).to have_http_status(:created)
      end
    end

    context "for an invalid request" do
      let(:errors){ ActiveModel::Errors.new(Object.new)  }

      let(:service_result) do
        ServiceResult.new.tap do |result|
          result.success = false
          result[:errors] = errors
        end
      end

      it "returns 422 status code" do
        post :create, request_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "assigns the list of errors" do
        post :create, request_attributes
        expect(assigns(:errors)).to eq(errors)
      end

      it "renders the shared/errors template" do
        post :create, request_attributes
        expect(response).to render_template("shared/errors")
      end
    end
  end

  describe '#destroy' do
    let(:request_attributes) { {format: 'json', album_id: 5678, media_type: "photos", media_type_id: "1"} }

    before :each do
      expect(RemoveMediaFromAlbumService).to receive(:invoke).and_return(service_result)
    end

    context "for valid request" do
      let(:service_result) do
        ServiceResult.new.tap do |result|
          result.success = true
        end
      end

      it "returns 204, no content if successful" do
        delete :destroy, request_attributes
        expect(response).to have_http_status(:no_content)
      end
    end

    context "for an invalid request" do
      let(:service_result) do
        ServiceResult.new.tap do |result|
          result.success = false
          result.errors[:base] = ["Unknown error"]
        end
      end

      it "returns a 422, unprocessable_entity if errors occurred" do
        delete :destroy, request_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the shared/errors template" do
        delete :destroy, request_attributes
        expect(response).to render_template("shared/errors")
      end
    end
  end
end
