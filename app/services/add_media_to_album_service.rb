class AddMediaToAlbumService < ServiceBase
  def execute!
    result = ServiceResult.new

    if content_list.save
      result.success = true
      result[:content_list] = content_list

      AverageDateUpdaterService.invoke(album_id: album_id)
    else
      result.success = false
      result[:errors] = content_list.errors
    end

    result
  end

  private

  def content_list
    @content_list ||= ContentList.new(album_id: album_id, asset_type: media_type_singular, asset_id: media_type_id)
  end

  def album_id
    options[:album_id]
  end

  def media_type
    options[:media_type]
  end

  def media_type_singular
    media_type.to_s.singularize.capitalize
  end

  def media_type_id
    options[:media_type_id]
  end
end
