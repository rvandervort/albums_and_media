class PhotosController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    respond_to do |format|
      format.json do
        result = GetPhotosService.invoke(page_number: params[:page], album_id: params[:album_id])
        if result.success?
          @photos = result[:photos]
        else
          render nothing: true, status: :unprocessable_entity
        end
      end
    end
  end

  def show
    respond_to do |format|
      result = FetchPhotoService.invoke(id: params[:id])

      format.json do
        if result.success?
          @photo = result[:photo]
        else
          render nothing: true, status: :not_found
        end
      end
    end
  end

  def create
    result = CreatePhotoService.invoke(photo: create_params.merge(album_id: params[:album_id]))

    respond_to do |format|
      format.json do
        if result.success?
          @photo = result[:photo]

          response.headers["Location"] = view_context.url_for(@photo)

          render :show, status: :created
        else
          @errors = result.errors
          render "shared/errors", status: :unprocessable_entity
        end
      end
    end
  end

  private

  def create_params
    params.require(:photo).permit(:album_id, :name, :position, :description, :url, :taken_at)
  end
end
