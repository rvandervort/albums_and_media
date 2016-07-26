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

    let(:successful_result) { double(:success? => true, :[] => model) }
    let(:unsuccessful_result) { double(:success? => false, :[] => []) }


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
      let(:valid_result) do
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

        expect(CreateAlbumService).to receive(:invoke).and_return(valid_result)
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
      let(:invalid_result) do 
        ServiceResult.new.tap do |result|
          result.success = false
          result[:album] = nil
          result[:errors] = ActiveModel::Errors.new(Object.new)
        end
      end
      
      before :each do
        expect(CreateAlbumService).to receive(:invoke).and_return(invalid_result)
      end

      it "returns 422 status code" do
        post :create, base_request_attributes.merge(:album => invalid_album_attributes)
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it "assigns the list of errors" do
        post :create, base_request_attributes.merge(:album => invalid_album_attributes)
        expect(assigns(:errors)).to eq({errors: invalid_result.errors})
      end
    end
  end

end
