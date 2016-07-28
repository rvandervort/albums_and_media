class AlbumFullValidator < ActiveModel::Validator
  def validate(record)
    @the_record = record

    if album_exists_and_is_full?
      the_record.errors.add(:album, "Album #{record.album_id} is full (max: #{Album.max_media}")
    end
  end

  private

  attr_reader :the_record

  def album
    the_record.album
  end

  def album_exists_and_is_full?
    !album.nil? && album.full?
  end
end
