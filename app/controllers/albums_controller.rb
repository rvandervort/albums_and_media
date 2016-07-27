class AlbumsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    respond_to do |format|
      format.json do
        result = GetAlbumsService.invoke(page_number: params[:page])

        if result.success?
          @albums = result[:albums]
          render json: @albums, status: :ok
        else
          render nothing: true, status: :unprocessable_entity
        end
      end
    end
  end

  def show
    respond_to do |format|
      result = FetchAlbumService.invoke(id: params[:id], with_photos: true)

      format.json do
        if result.success?
          @album = result[:album]
          @photos = result[:photos]
        else
          render nothing: true, status: :not_found
        end
      end
    end
  end

  def create
    result = CreateAlbumService.invoke(album: create_params)

    respond_to do |format|
      format.json do
        if result.success?
          @album = result[:album]

          response.headers["Location"] = view_context.url_for(@album)
          render json: @album, status: :created
        else
          @errors = {errors: result.errors}
          render json: @errors, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    result = UpdateAlbumService.invoke({id: params[:id], album: update_params})
    respond_to do |format|
      format.json do
        if result.success?
          render nothing: true, status: :ok
        else
          @errors = {errors: result.errors}
          render json: @errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    result = DestroyAlbumService.invoke(id: params[:id])

    respond_to do |format|
      format.json do
        if result.success?
          render nothing: true, status: :no_content
        else
          if result[:album_not_found]
            render nothing: true, status: :not_found
          else
            @errors = result.errors
            render json: @errors, status: :unprocessable_entity
          end
        end
      end
    end
  end

  private

  def create_params
    params.require(:album).permit(:name, :position, :description)
  end

  def update_params
    params.require(:album).permit(:name, :position, :description)
  end
end
