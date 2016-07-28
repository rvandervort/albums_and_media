class CreatePhotoService < ServiceBase
  def execute!
    result = ServiceResult.new

    photo = Photo.new(attributes)

    if photo.save
      result.success = true
      result[:photo] = photo

      AverageDateUpdaterService.invoke(album_id: photo.album_id)
    else
      result.success = false
      result[:errors] = photo.errors
    end

    result
  end


  private

  def attributes
    options.fetch(:photo, {})
  end
end
