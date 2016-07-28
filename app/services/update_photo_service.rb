class UpdatePhotoService < ServiceBase
  def execute!
    if photo_record
      update_photo
    else
      invalid_record
    end
  end

  private

  def update_photo
    result = ServiceResult.new

    old_album_id = photo_record.album_id

    if photo_record.update(attributes)
      result.success = true
      result[:photo] = photo_record

      update_average_dates(old_album_id, attributes[:album_id])
    else
      result.success = false
      result[:errors] = photo_record.errors
    end

    result
  end

  def update_average_dates(old_album_id, new_album_id)
    unless new_album_id.nil?
      if old_album_id != new_album_id
        AverageDateUpdaterService.invoke(id: old_album_id)
        AverageDateUpdaterService.invoke(id: attributes[:album_id])
      end
    end
  end

  def invalid_record
    ServiceResult.new.tap do |result|
      result.success = false
      result.errors[:base] = ["Photo with id #{id} not found"]
    end
  end


  def id
    options[:id]
  end

  def attributes
    options.fetch(:photo, {})
  end

  def photo_record
    @photo ||= retrieve_photo
  end

  def retrieve_photo
    result = FetchPhotoService.invoke({id: id})
    result.success? ? result[:photo] : nil
  end
end
