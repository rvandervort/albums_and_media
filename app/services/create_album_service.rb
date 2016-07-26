class CreateAlbumService < ServiceBase
  def execute!
    result = ServiceResult.new

    album = Album.new(attributes)

    if album.save
      result.success = true
      result[:album] = album
    else
      result.success = false
      result[:errors] = album.errors
    end

    result
  end

  private

  def attributes
    options[:album]
  end
end
