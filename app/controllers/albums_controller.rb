class AlbumsController < ApplicationController
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
end
