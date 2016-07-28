class VideosController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    respond_to do |format|
      format.json do
        result = GetMediaService.invoke(media_type: Video, page_number: params[:page], album_id: params[:album_id])
        if result.success?
          @videos = result[:videos]
        else
          render nothing: true, status: :unprocessable_entity
        end
      end
    end
  end

  def show
    respond_to do |format|
      result = FetchMediaService.invoke(media_type: Video, id: params[:id])

      format.json do
        if result.success?
          @video = result[:video]
        else
          render nothing: true, status: :not_found
        end
      end
    end
  end

  def create
    if create_single_video?
      create_single
    elsif create_multiple_videos?
      create_multiple
    else
      render nothing: true, status: :unprocessable_entity
    end
  end



  def update
    result = UpdateMediaService.invoke({media_type: Video, id: params[:id], video: update_params})

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
    result = DestroyMediaService.invoke(media_type: Video, id: params[:id])

    respond_to do |format|
      format.json do
        if result.success?
          render nothing: true, status: :no_content
        else
          if result[:video_not_found]
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
    result = CreateMediaService.invoke(media_type: Video, video: create_params.merge(album_id: params[:album_id]))

    respond_to do |format|
      format.json do
        if result.success?
          @video = result[:video]

          response.headers["Location"] = view_context.url_for(@video)

          render :show, status: :created
        else
          @errors = result.errors
          render "shared/errors", status: :unprocessable_entity
        end
      end
    end
  end

  def create_multiple
    result = CreateMultipleMediaService.invoke(params.merge(media_type: Video))

    respond_to do |format|
      format.json do
        if result.success?
          @videos = result[:videos]
          render 'videos/multiple', status: :created
        else
          @videos = result[:attributes_and_errors]
          render 'videos/multiple', status: :unprocessable_entity
        end
      end
    end
  end

  def create_single_video?
    params.has_key?(:video) && !params.has_key?(:videos)
  end

  def create_multiple_videos?
    params.has_key?(:videos)
  end

  def create_params
    params.require(:video).permit(:album_id, :name, :position, :description, :url, :taken_at)
  end

  def update_params
    params.require(:video).permit(:album_id, :name, :position, :description, :url, :taken_at)
  end
end
