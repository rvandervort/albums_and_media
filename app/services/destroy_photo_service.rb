class DestroyPhotoService < ServiceBase
  def execute!
    if photo
      destroy_photo
    else
      basic_error(ServiceResult.new, false)
    end
  end

  private

  def destroy_photo
    ServiceResult.new.tap do |result|
      if photo.destroy
        result.success = true
        AverageDateUpdaterService.invoke(album_id: photo.album_id)

      else
        basic_error(result, true)
      end
    end
  end

  def photo
    @photo ||= retrieve_photo
  end

  def basic_error(result, photo_exists)
    result.success = false
    result.errors[:base] = ["Unable to delete photo with id #{id}"]

    result[:photo_not_found] = !photo_exists
    result
  end

  def retrieve_photo
    result = FetchPhotoService.invoke(id: id)
    (result.success?) ? result[:photo] : nil
  end

  def id
    options[:id]
  end
end
