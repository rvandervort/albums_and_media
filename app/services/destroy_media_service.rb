class DestroyMediaService < ServiceBase
  def execute!
    if asset
      destroy_asset
    else
      basic_error(ServiceResult.new, false)
    end
  end

  private

  def destroy_asset
    ServiceResult.new.tap do |result|
      if asset.destroy
        result.success = true
        AverageDateUpdaterService.invoke(album_id: asset.album_id)

      else
        basic_error(result, true)
      end
    end
  end

  def asset
    @asset ||= retrieve_asset
  end

  def basic_error(result, asset_exists)
    result.success = false
    result.errors[:base] = ["Unable to delete #{media_type_name} with id #{id}"]

    result["#{media_type_name}_not_found".to_sym] = !asset_exists
    result
  end

  def retrieve_asset
    result = FetchMediaService.invoke(media_type: media_type, id: id)
    (result.success?) ? result[media_type_name] : nil
  end

  def id
    options[:id]
  end

  def media_type
    options.fetch(:media_type, Photo)
  end

  def media_type_name
    media_type.name.downcase.to_sym
  end
end
