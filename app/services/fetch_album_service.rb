class FetchAlbumService < ServiceBase
  def execute!
    result = ServiceResult.new

    begin
      result[:album] = Album.find(id)
      result.success = true
      result[:photos] = retrieve_photos if include_photos?
      result[:videos] = retrieve_videos if include_videos?

    rescue ActiveRecord::RecordNotFound => arnf
      result.errors[:base] = ["Album with id #{id} not found"]
      result.success = false
    rescue Exception => e
      result.errors[:base] = [e.to_s]
      result.success = false
    end

    result
  end

  private

  def id
    options[:id]
  end

  def retrieve_photos
    result = GetMediaService.invoke(media_type: Photo, album_id: id)
    result.success? ? result[:photos] : []
  end

  def retrieve_videos
    result = GetMediaService.invoke(media_type: Video, album_id: id)
    result.success? ? result[:videos] : []
  end


  def include_photos?
    options[:with_photos] == true
  end

  def include_videos?
    options[:with_videos] == true
  end
end
