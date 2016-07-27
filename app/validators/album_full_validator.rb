class AlbumFullValidator < ActiveModel::Validator
  def validate(record)
    @photo = record

    if album_exists_and_is_full?
      photo.errors.add(:album, "Album #{record.album_id} is full (max: #{Album.max_photos}")
    end
  end

  private

  attr_reader :photo

  def album
    photo.album
  end

  def album_exists_and_is_full?
    !album.nil? && album.full?
  end
end
