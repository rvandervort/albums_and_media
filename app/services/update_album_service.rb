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
     perform_update do |result|
        if album_record.update(attributes)
          result.success = true
          result[:album] = album_record
        else
          result.success = false
          result[:errors] = album_record.errors
        end
     end
  end

  def perform_update
    result = ServiceResult.new

    old_position = album_record.position

    Album.transaction do
      yield result

      if old_position != album_record.position
        if result.success?
          shift_albums(album_record.id, old_position, album_record.position)
        end
      end
    end

    result
  end

  def shift_albums(id, old_position, new_position)
    update_clause = ""
    where_clause = "id <> #{id} AND "

    if new_position < old_position
      update_clause = "position = position + 1"
      where_clause = where_clause + "position >= #{new_position} AND position < #{old_position}"
    elsif new_position > old_position
      update_clause = "position = position - 1"
      where_clause = where_clause + "position > #{old_position} AND position <= #{new_position}"
    else
      where_clause = "1 == 2"
    end

    Album.where(where_clause).update_all(update_clause)
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

  def update_position?
    position_provided? && positions_are_different?
  end

  def position_provided?
    !attributes[:position].blank?
  end

  def positions_are_different?
    album_record.position != attributes[:position]
  end

  def attributes
    options.fetch(:album, {})
  end

  def album_record
    @album ||= begin
                  Album.find(id)
               rescue ActiveRecord::RecordNotFound
                  nil
               end
  end
end
