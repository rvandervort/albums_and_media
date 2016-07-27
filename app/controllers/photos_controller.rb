class PhotosController < ApplicationController
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
end
