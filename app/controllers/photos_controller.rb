class PhotosController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    respond_to do |format|
      format.json do
        result = GetMediaService.invoke(page_number: params[:page], album_id: params[:album_id])
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
      result = FetchMediaService.invoke(media_type: Photo, id: params[:id])

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
    if create_single_photo?
      create_single
    elsif create_multiple_photos?
      create_multiple
    else
      render nothing: true, status: :unprocessable_entity
    end
  end



  def update
    result = UpdateMediaService.invoke({media_type: Photo, id: params[:id], photo: update_params})

    respond_to do |format|
      format.json do
        if result.success?
          render nothing: true, status: :ok
        else
          @errors = result.errors
          render 'shared/errors', status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    result = DestroyMediaService.invoke(media_type: Photo, id: params[:id])

    respond_to do |format|
      format.json do
        if result.success?
          render nothing: true, status: :no_content
        else
          if result[:photo_not_found]
            render nothing: true, status: :not_found
          else
            @errors = result.errors
            render 'shared/errors', status: :unprocessable_entity
          end
        end
      end
    end
  end

  private

  def create_single
    result = CreateMediaService.invoke(media_type: Photo, photo: create_params, album_id: params[:album_id])

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

  def create_multiple
    result = CreateMultipleMediaService.invoke(params)

    respond_to do |format|
      format.json do
        if result.success?
          @photos = result[:photos]
          render 'photos/multiple', status: :created
        else
          @photos = result[:attributes_and_errors]
          render 'photos/attributes_and_errors', status: :unprocessable_entity
        end
      end
    end
  end

  def create_single_photo?
    params.has_key?(:photo) && !params.has_key?(:photos)
  end

  def create_multiple_photos?
    params.has_key?(:photos)
  end

  def create_params
    params.require(:photo).permit(:album_id, :name, :position, :description, :url, :taken_at)
  end

  def update_params
    params.require(:photo).permit(:album_id, :name, :position, :description, :url, :taken_at)
  end
end
