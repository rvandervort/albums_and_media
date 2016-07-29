class UpdateMediaService < ServiceBase
  def execute!
    if asset_record
      update_asset
    else
      invalid_record
    end
  end

  private

  def update_asset
    result = ServiceResult.new

    if asset_record.update(attributes)
      result.success = true
      result[media_class_name] = asset_record

    else
      result.success = false
      result[:errors] = asset_record.errors
    end

    result
  end

  def invalid_record
    ServiceResult.new.tap do |result|
      result.success = false
      result.errors[:base] = ["#{media_class.name} with id #{id} not found"]
    end
  end


  def id
    options[:id]
  end

  def attributes
    options.fetch(media_class_name, {})
  end

  def asset_record
    @asset ||= retrieve_asset
  end

  def retrieve_asset
    result = FetchMediaService.invoke(media_type: media_class, id: id)
    result.success? ? result[media_class_name] : nil
  end

  def media_class
    options.fetch(:media_class, Photo)
  end

  def media_class_name
    media_class.name.downcase.to_sym
  end
end
  
