class CreateMediaService < ServiceBase
  def execute!
    result = ServiceResult.new

    model = media_class.new(attributes)

    if model.save
      result.success = true
      result[media_class_sym] = model

      AverageDateUpdaterService.invoke(album_id: model.album_id)
    else
      result.success = false
      result[:errors] = model.errors
    end

    result
  end


  private

  def media_class
    options.fetch(:media_class, Photo)
  end

  def media_class_sym
    media_class.name.downcase.to_sym
  end

  def attributes
    options.fetch(media_class_sym, {})
  end
end
