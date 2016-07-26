class UpdateAlbumService < ServiceBase
  def execute!
    if album_record
      update_album
    else
      invalid_record
    end
  end

  private

  def update_album
    ServiceResult.new.tap do |result|
      if album_record.update(attributes)
        result.success = true
        result[:album] = album_record
      else
        result.success = false
        result[:errors] = album_record.errors
      end
    end
  end

  def invalid_record
    ServiceResult.new.tap do |result|
      result.success = false
      result.errors[:base] = ["Album with id #{id} not found"]
    end
  end


  def id
    options[:id]
  end

  def attributes
    options[:album]
  end

  def album_record
    @album ||= begin
                  Album.find(id)
               rescue ActiveRecord::RecordNotFound
                  nil
               end
  end
end
