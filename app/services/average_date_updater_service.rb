class AverageDateUpdaterService < ServiceBase
  def execute!
    result = ServiceResult.new

    if album
      result[:old_date] = album.average_date
      result[:new_date] = recalculate_and_save_date

      result.success = true
    else
      result.success = false
      result.errors[:base] = ["Album with id #{album_id} does not exist"]
    end

    result
  end

  private

  def recalculate_and_save_date
    if times.empty?
      album.average_date = nil
    else
      average_time = Time.zone.at((times.reduce(:+) / times.count).to_i)

      album.average_date = average_time.to_date
    end

    album.save

    album.average_date
  end

  def times
    album.photos.pluck(:taken_at).map(&:to_i)
  end

  def album_id
    options[:album_id]
  end

  def album
    @album ||= begin
                 result = FetchAlbumService.invoke(id: album_id)
                 result.success? ? result[:album] : nil
               end
  end
end
