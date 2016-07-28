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

  describe '#show' do
    let(:base_request_attributes) { {format: 'json'} }
    let(:model) { Photo.new(name: 'test album') }

    let(:successful_result) {
      ServiceResult.new.tap do |result|
        result.success = true
        result[:photo] = model
      end
    }

    let(:unsuccessful_result) {
      ServiceResult.new.tap do |result|
        result.success = false
      end
    }


    it 'responds with a 200, if the photo is found' do
      expect(FetchPhotoService).to receive(:invoke).and_return(successful_result)
      get :show, base_request_attributes.merge(:id => 1)
      expect(response).to have_http_status(:ok)
    end

    it 'sets the photo, if the photo is found' do
      expect(FetchPhotoService).to receive(:invoke).and_return(successful_result)
      get :show, base_request_attributes.merge(:id => 1)
      expect(assigns(:photo)).to eq(model)
    end

    it 'responds with a 404, if the photo is not found' do
      expect(FetchPhotoService).to receive(:invoke).and_return(unsuccessful_result)
      get :show, base_request_attributes.merge(:id => 1)
      expect(response).to have_http_status(:not_found)
    end
  end


  describe '#create', :db => true do
    let(:base_request_attributes) { {format: 'json', album_id: 5678} }
    
    context 'for a valid request, with valid data' do
      let(:valid_photo_attributes) { {name: "My brand new photo"} }
      let(:model) { Photo.new(valid_photo_attributes) }
      let(:successful_result) do
        ServiceResult.new.tap do |result|
          result.success = true
          result[:photo] = model
        end
      end

      before :each do
        # Fake out polymorphic routes #handle_model so
        # we get back /albums/5678/photo/1123 when asking for the model's url
        model.id = 1123
        expect(model).to receive(:persisted?).and_return(true)

        expect(CreatePhotoService).to receive(:invoke).and_return(successful_result)
      end

      it "returns status 201 created" do
        post :create, base_request_attributes.merge(:photo => valid_photo_attributes)
        expect(response).to have_http_status(:created)
      end

      it "assigns the photo" do
        post :create, base_request_attributes.merge(:photo => valid_photo_attributes)
        expect(assigns(:photo)).to eq(model)
      end

      it "returns the location of the created photo in the response headers" do
        post :create, base_request_attributes.merge(:photo => valid_photo_attributes)
        expect(response.headers["Location"]).to match(/photos\/1123/)
      end
    end

    context "for an invalid request" do
      let(:invalid_photo_attributes) { {name: ""} }
      let(:errors){ ActiveModel::Errors.new(Object.new)  }
      let(:unsuccessful_result) do
        ServiceResult.new.tap do |result|
          result.success = false
          result[:photo] = nil
          result[:errors] = errors
        end
      end

      before :each do
        expect(CreatePhotoService).to receive(:invoke).and_return(unsuccessful_result)
      end

      it "returns 422 status code" do
        post :create, base_request_attributes.merge(:photo => invalid_photo_attributes)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "assigns the list of errors" do
        post :create, base_request_attributes.merge(:photo => invalid_photo_attributes)
        expect(assigns(:errors)).to eq(errors)
      end
    end
  end

  describe '#update' do
    let(:base_request_attributes) { {id: "1123", format: 'json'} }

    context 'for a valid request, with valid data' do
      let(:valid_photo_attributes) { {url: "http://sdf.jpg", name: "My brand new photo"} }
      let(:model) { Photo.new(valid_photo_attributes) }
      let(:successful_result) do
        ServiceResult.new.tap do |result|
          result.success = true
          result[:photo] = model
        end
      end

      before :each do
        expect(UpdatePhotoService).to receive(:invoke).and_return(successful_result)
      end

      it "returns http status 200 OK" do
        put :update, base_request_attributes.merge(:photo => valid_photo_attributes)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'for an valid request, with invalid data' do
      let(:valid_photo_attributes) { {name: "My brand new photo"} }
      let(:model) { Photo.new(valid_photo_attributes) }
      let(:errors) { double() }

      let(:unsuccessful_result) do
        ServiceResult.new.tap do |result|
          result.success = false
          result[:errors] = errors
        end
      end

      before :each do
        expect(UpdatePhotoService).to receive(:invoke).and_return(unsuccessful_result)
      end

      it "returns a 422 unprocessable entity" do
        put :update, base_request_attributes.merge(:photo => valid_photo_attributes)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "assigns the @errors" do
        put :update, base_request_attributes.merge(:photo => valid_photo_attributes)
        expect(assigns(:errors)).to eq(errors)
      end

    end
  end
end
