class RemoveMediaFromAlbumService < ServiceBase
  def execute!
    result = ServiceResult.new

    if content_list
      destroy_content_list

    else
      no_membership_error
    end
  end

  private

  def destroy_content_list
    ServiceResult.new.tap do |result|
      media = content_list.asset

      if content_list.destroy
        result.success = true
        AverageDateUpdaterService.invoke(album_id: album_id)

        destroy_media(media) if media.albums.empty?
      else
        result.success = false
        result[:errors] = content_list.errors
      end
    end
  end

  def destroy_media(asset)
    DestroyMediaService.invoke(media_type: asset.class, id: asset.id) 
  end

  def no_membership_error
    ServiceResult.new.tap do |result|
      result.success = false
      result[:errors] = {base: ["no #{media_type_singular} with id #{media_type_id} in album #{album_id}"]}
    end
  end

  def content_list
    @content_list ||= ContentList.find_by(album_id: album_id, asset_type: media_type_singular, asset_id: media_type_id)
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
