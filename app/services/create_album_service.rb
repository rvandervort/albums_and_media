class CreateAlbumService < ServiceBase
  def execute!
    result = ServiceResult.new

    Album.transaction do
      attributes[:position] ||= default_position

      album = Album.new(attributes)

      if album.save
        result.success = true
        result[:album] = album

        shift_albums(album.id, album.position)
      else
        result.success = false
        result[:errors] = album.errors
      end
    end

    result
  end

  private

  def shift_albums(album_id, positions_greater_than_or_eq_to)
    albums_to_shift(album_id, positions_greater_than_or_eq_to).update_all("position = position + 1")
  end

  def albums_to_shift(id, from_position)
    Album.where("id <> ? AND position >= ?", id, from_position)
  end

  def default_position
    (Album.maximum(:position)  + 1) rescue 0
  end

  def attributes
    options.fetch(:album, {})
  end
end
