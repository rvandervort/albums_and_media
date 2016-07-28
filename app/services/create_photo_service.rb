class CreatePhotoService < ServiceBase
  def execute!
    result = ServiceResult.new

    photo = Photo.new(attributes)

    if photo.save
      result.success = true
      result[:photo] = photo

      update_album_average_date(photo.album)
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

  def update_album_average_date(album)
    times = album.photos.pluck(:taken_at).map(&:to_i)

    average_time = Time.zone.at((times.reduce(:+) / times.count).to_i)

    album.average_date = average_time.to_date
    album.save
  end
end
