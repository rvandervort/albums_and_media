class ContentListsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    result = AddMediaToAlbumService.invoke(params)

    respond_to do |format|
      format.json do
        if result.success?
          render nothing: true, status: :created
        else
          @errors = result.errors
          render "shared/errors", status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    result = RemoveMediaFromAlbumService.invoke(params)

    respond_to do |format|
      format.json do
        if result.success?
          render nothing: true, status: :no_content
        else
          @errors = result.errors
          render 'shared/errors', status: :unprocessable_entity
        end
      end
    end
  end
end
