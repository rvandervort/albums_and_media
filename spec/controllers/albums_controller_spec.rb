require 'rails_helper'

RSpec.describe AlbumsController, type: :controller do
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

      it "returns 200 ok" do
        get :index, request_attributes
        expect(response).to have_http_status(:ok)
      end

      it "sets provides the resulting list of albums" do
        get :index, request_attributes
        expect(assigns(:albums)).to be_a(Album::ActiveRecord_Relation)
      end
    end
  end

  describe '#show' do
    let(:base_request_attributes) { {format: 'json'} }
    let(:model) { Album.new(name: 'test album') }
    let(:photos) { 3.times.map { |i| Photo.new(name: "Photo") } }

    let(:successful_result) {
      ServiceResult.new.tap do |result|
        result.success = true
        result[:album] = model
        result[:photos] = photos
      end
    }

    let(:unsuccessful_result) {
      ServiceResult.new.tap do |result|
        result.success = false
      end
    }


    it 'responds with a 200, if the album is found' do
      expect(FetchAlbumService).to receive(:invoke).and_return(successful_result)
      get :show, base_request_attributes.merge(:id => 1)
      expect(response).to have_http_status(:ok)
    end

    it 'sets the album, if the album is found' do
      expect(FetchAlbumService).to receive(:invoke).and_return(successful_result)
      get :show, base_request_attributes.merge(:id => 1)
      expect(assigns(:album)).to eq(model)
    end

    it 'sets the photos, if the album was found' do
      expect(FetchAlbumService).to receive(:invoke).and_return(successful_result)
      get :show, base_request_attributes.merge(:id => 1)
      expect(assigns(:photos)).to eq(photos)
    end

    it 'responds with a 404, if the album is not found' do
      expect(FetchAlbumService).to receive(:invoke).and_return(unsuccessful_result)
      get :show, base_request_attributes.merge(:id => 1)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe '#create' do
    let(:base_request_attributes) { {format: 'json'} }

    context 'for a valid request, with valid data' do
      let(:valid_album_attributes) { {name: "My brand new album"} }
      let(:model) { Album.new(valid_album_attributes) }
      let(:successful_result) do
        ServiceResult.new.tap do |result|
          result.success = true
          result[:album] = model
        end
      end

      before :each do
        # Fake out polymorphic routes #handle_model so
        # we get back /albums/1123 when asking for the model's url
        model.id = 1123
        expect(model).to receive(:persisted?).and_return(true)

        expect(CreateAlbumService).to receive(:invoke).and_return(successful_result)
      end

      it "returns status 201 created" do
        post :create, base_request_attributes.merge(:album => valid_album_attributes)
        expect(response).to have_http_status(:created)
      end

      it "assigns the album" do
        post :create, base_request_attributes.merge(:album => valid_album_attributes)
        expect(assigns(:album)).to eq(model)
      end

      it "returns the location of the created album in the response headers" do
        post :create, base_request_attributes.merge(:album => valid_album_attributes)
        expect(response.headers["Location"]).to match(/albums\/1123/)
      end
    end

    context "for an invalid request" do
      let(:invalid_album_attributes) { {name: ""} }
      let(:errors){ ActiveModel::Errors.new(Object.new)  }
      let(:unsuccessful_result) do
        ServiceResult.new.tap do |result|
          result.success = false
          result[:album] = nil
          result[:errors] = errors
        end
      end

      before :each do
        expect(CreateAlbumService).to receive(:invoke).and_return(unsuccessful_result)
      end

      it "returns 422 status code" do
        post :create, base_request_attributes.merge(:album => invalid_album_attributes)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "assigns the list of errors" do
        post :create, base_request_attributes.merge(:album => invalid_album_attributes)
        expect(assigns(:errors)).to eq(errors)
      end
    end
  end

  describe '#update' do
    let(:base_request_attributes) { {id: "1123", format: 'json'} }

    context 'for a valid request, with valid data' do
      let(:valid_album_attributes) { {name: "My brand new album"} }
      let(:model) { Album.new(valid_album_attributes) }
      let(:successful_result) do
        ServiceResult.new.tap do |result|
          result.success = true
          result[:album] = model
        end
      end

      before :each do
        expect(UpdateAlbumService).to receive(:invoke).and_return(successful_result)
      end

      it "returns http status 200 OK" do
        put :update, base_request_attributes.merge(:album => valid_album_attributes)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'for an valid request, with invalid data' do
      let(:valid_album_attributes) { {name: "My brand new album"} }
      let(:model) { Album.new(valid_album_attributes) }
      let(:errors) { double() }

      let(:unsuccessful_result) do
        ServiceResult.new.tap do |result|
          result.success = false
          result[:errors] = errors
        end
      end

      before :each do
        expect(UpdateAlbumService).to receive(:invoke).and_return(unsuccessful_result)
      end

      it "returns a 422 unprocessable entity" do
        put :update, base_request_attributes.merge(:album => valid_album_attributes)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "assigns the @errors" do
        put :update, base_request_attributes.merge(:album => valid_album_attributes)
        expect(assigns(:errors)).to eq(errors)
      end

    end
  end

  describe '#destroy' do
    let(:base_request_attributes) { {format: 'json'} }
    let(:request_attributes) { base_request_attributes.merge({id: 1}) }
    let(:successful_result) {
      ServiceResult.new.tap do |result|
        result.success = true
      end
    }

    let(:unsuccessful_result) do
      ServiceResult.new.tap do |result|
        result.success = false
        result.errors[:base] = ["Unknown error"]
      end
    end

    let(:album_doesnt_exist_result) {
      ServiceResult.new.tap do |result|
        result.success = false
        result.errors[:base] = ["Album does not exist"]
        result[:album_not_found] = true
      end
    }

    it "returns 204, no content if successful" do
      expect(DestroyAlbumService).to receive(:invoke).and_return(successful_result)

      delete :destroy, request_attributes
      expect(response).to have_http_status(:no_content)
    end

    it "returns a 404 if the album doesn't exist" do
      expect(DestroyAlbumService).to receive(:invoke).and_return(album_doesnt_exist_result)
      delete :destroy, request_attributes
      expect(response).to have_http_status(:not_found)
    end

    it "returns a 422, unprocessable_entity if other errors occurred" do
      expect(DestroyAlbumService).to receive(:invoke).and_return(unsuccessful_result)
      delete :destroy, request_attributes
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

end
