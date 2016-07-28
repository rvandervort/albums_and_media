require 'rails_helper'

RSpec.shared_examples "A media controller for asset type" do |asset_type, valid_file_extension|
  let(:asset_type_name) { asset_type.name.downcase.to_sym }
  let(:plural_asset_type_name) { "#{asset_type_name}".pluralize.to_sym }

  let(:media_service_base_name) { "#{asset_type.name.capitalize}Service" }
  let(:get_media_service) { "Get#{asset_type.name.pluralize.capitalize}Service".constantize }
  let(:create_multiple_media_service) { "CreateMultiple#{asset_type.name.pluralize.capitalize}Service".constantize }
  let(:fetch_media_service) { "Fetch#{media_service_base_name}".constantize }
  let(:create_media_service) { CreateMediaService }
  let(:destroy_media_service) { "Destroy#{media_service_base_name}".constantize }
  let(:update_media_service) { "Update#{media_service_base_name}".constantize }

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
      let(:records) { double() }

      let(:successful_result) {
        ServiceResult.new.tap do |result|
          result.success = true
          result[plural_asset_type_name] = records
        end
      }

      before :each do
        expect(get_media_service).to receive(:invoke).and_return(successful_result)
      end

      it "returns 200 ok" do
        get :index, request_attributes
        expect(response).to have_http_status(:ok)
      end

      it "sets provides the resulting list of #{asset_type.name.pluralize}" do
        get :index, request_attributes
        expect(assigns(plural_asset_type_name)).to eq(records)
      end
    end
  end

  describe '#show' do
    let(:base_request_attributes) { {format: 'json'} }
    let(:model) { asset_type.new(name: 'test asset') }

    let(:successful_result) {
      ServiceResult.new.tap do |result|
        result.success = true
        result[asset_type_name] = model
      end
    }

    let(:unsuccessful_result) {
      ServiceResult.new.tap do |result|
        result.success = false
      end
    }


    it 'responds with a 200, if the asset is found' do
      expect(fetch_media_service).to receive(:invoke).and_return(successful_result)
      get :show, base_request_attributes.merge(:id => 1)
      expect(response).to have_http_status(:ok)
    end

    it "sets the asset, if is found" do
      expect(fetch_media_service).to receive(:invoke).and_return(successful_result)
      get :show, base_request_attributes.merge(:id => 1)
      expect(assigns(asset_type_name)).to eq(model)
    end

    it "responds with a 404, if the asset is not found" do
      expect(fetch_media_service).to receive(:invoke).and_return(unsuccessful_result)
      get :show, base_request_attributes.merge(:id => 1)
      expect(response).to have_http_status(:not_found)
    end
  end


  describe '#create', :db => true do
    let(:base_request_attributes) { {format: 'json', album_id: 5678} }

    context 'for a single asset' do
      context 'for a valid request, with valid data' do
        let(:valid_attributes) { {name: "My brand new asset"} }
        let(:model) { asset_type.new(valid_attributes) }
        let(:successful_result) do
          ServiceResult.new.tap do |result|
            result.success = true
            result[asset_type_name] = model
          end
        end

        before :each do
          # Fake out polymorphic routes #handle_model so
          # we get back /albums/5678/{asset type}/1123 when asking for the model's url
          model.id = 1123
          expect(model).to receive(:persisted?).and_return(true)

          expect(CreateMediaService).to receive(:invoke).and_return(successful_result)
        end

        it "returns status 201 created" do
          post :create, base_request_attributes.merge("#{asset_type_name}".to_sym => valid_attributes)
          expect(response).to have_http_status(:created)
        end

        it "assigns the asset" do
          post :create, base_request_attributes.merge("#{asset_type_name}".to_sym => valid_attributes)
          expect(assigns(asset_type_name)).to eq(model)
        end

        it "returns the location of the created asset in the response headers" do
          post :create, base_request_attributes.merge("#{asset_type_name}".to_sym => valid_attributes)
          expect(response.headers["Location"]).to match("#{plural_asset_type_name}/1123")
        end
      end

      context "for an invalid request" do
        let(:invalid_attributes) { {name: ""} }
        let(:errors){ ActiveModel::Errors.new(Object.new)  }
        let(:unsuccessful_result) do
          ServiceResult.new.tap do |result|
            result.success = false
            result[asset_type_name] = nil
            result[:errors] = errors
          end
        end

        before :each do
          expect(CreateMediaService).to receive(:invoke).and_return(unsuccessful_result)
        end

        it "returns 422 status code" do
          post :create, base_request_attributes.merge("#{asset_type_name}".to_sym => invalid_attributes)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "assigns the list of errors" do
          post :create, base_request_attributes.merge("#{asset_type_name}".to_sym => invalid_attributes)
          expect(assigns(:errors)).to eq(errors)
        end
      end
    end

    context 'for multiplie assets' do
      let(:media_list) { [{id: 123}, {id: 234}] }

      before :each do
        expect(create_multiple_media_service).to receive(:invoke).and_return(service_result)
        expect(create_media_service).not_to receive(:invoke)
      end

      context "for a valid request" do
        let(:service_result) {
          ServiceResult.new.tap do |result|
            result.success = true
            result[plural_asset_type_name] = media_list
          end
        }

        it "returns 201 status code" do
          post :create, base_request_attributes.merge("#{plural_asset_type_name}".to_sym => media_list)
          expect(response).to have_http_status(:created)
        end

        it "assigns the assets" do
          post :create, base_request_attributes.merge("#{plural_asset_type_name}".to_sym => media_list)
          expect(assigns(plural_asset_type_name)).to eq(media_list)
        end
      end


      context "for an invalid request" do
        let(:service_result) {
          ServiceResult.new.tap do |result|
            result.success = false
            result[:attributes_and_errors] = ["an attributes and errors list"]
          end
        }

        it "returns 422 status code" do
          post :create, base_request_attributes.merge("#{plural_asset_type_name}".to_sym => media_list)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "assigns the assets, with errors for each" do
          post :create, base_request_attributes.merge("#{plural_asset_type_name}".to_sym => media_list)
          expect(assigns(plural_asset_type_name)).to eq(service_result[:attributes_and_errors])
        end
      end
    end

  end

  describe '#update' do
    let(:base_request_attributes) { {id: "1123", format: 'json'} }

    context 'for a valid request, with valid data' do
      let(:valid_attributes) { {url: "http://sdf.#{valid_file_extension}", name: "My brand new asset"} }
      let(:model) { asset_type.new(valid_attributes) }
      let(:successful_result) do
        ServiceResult.new.tap do |result|
          result.success = true
          result[asset_type_name] = model
        end
      end

      before :each do
        expect(update_media_service).to receive(:invoke).and_return(successful_result)
      end

      it "returns http status 200 OK" do
        put :update, base_request_attributes.merge("#{asset_type_name}".to_sym => valid_attributes)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'for an valid request, with invalid data' do
      let(:valid_attributes) { {name: "My brand new asset"} }
      let(:model) { asset_type.new(valid_attributes) }
      let(:errors) { double() }

      let(:unsuccessful_result) do
        ServiceResult.new.tap do |result|
          result.success = false
          result[:errors] = errors
        end
      end

      before :each do
        expect(update_media_service).to receive(:invoke).and_return(unsuccessful_result)
      end

      it "returns a 422 unprocessable entity" do
        put :update, base_request_attributes.merge(asset_type_name => valid_attributes)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "assigns the @errors" do
        put :update, base_request_attributes.merge(asset_type_name => valid_attributes)
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

    let(:asset_doesnt_exist_result) {
      ServiceResult.new.tap do |result|
        result.success = false
        result.errors[:base] = ["Asset does not exist"]
        result["#{asset_type_name}_not_found".to_sym] = true
      end
    }

    it "returns 204, no content if successful" do
      expect(destroy_media_service).to receive(:invoke).and_return(successful_result)

      delete :destroy, request_attributes
      expect(response).to have_http_status(:no_content)
    end

    it "returns a 404 if the asset doesn't exist" do
      expect(destroy_media_service).to receive(:invoke).and_return(asset_doesnt_exist_result)
      delete :destroy, request_attributes
      expect(response).to have_http_status(:not_found)
    end

    it "returns a 422, unprocessable_entity if other errors occurred" do
      expect(destroy_media_service).to receive(:invoke).and_return(unsuccessful_result)
      delete :destroy, request_attributes
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
