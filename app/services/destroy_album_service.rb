class DestroyAlbumService < ServiceBase
  def execute!
    if album
      destroy_album
    else
      basic_error(ServiceResult.new, false)
    end
  end

  private

  def destroy_album
    ServiceResult.new.tap do |result|
      Album.transaction do
        if album.destroy
          result.success = true
          shift_other_albums(album.position)
        else
          basic_error(result, true)
        end
      end
    end
  end

  def album
    @album ||= retrieve_album
  end

  def basic_error(result, album_exists)
    result.success = false
    result.errors[:base] = ["Unable to delete album with id #{id}"]

    result[:album_not_found] = !album_exists
    result
  end


  def retrieve_album
    result = FetchAlbumService.invoke(id: id)
    (result.success?) ? result[:album] : nil
  end

  def id
    options[:id]
  end

  def shift_other_albums(position)
      Album.where("position >= #{position}").update_all("position = position - 1")
  end
end
