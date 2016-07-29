class CreateMediaService < ServiceBase
  def execute!
    if album
      if album.full?
        album_is_full
      else
        create_model
      end
    else
      invalid_album
    end
  end


  private

  def create_model
    result = ServiceResult.new

    model = media_class.new(attributes)

    if model.save
      result.success = true
      result[media_class_sym] = model

      create_content_list_entry(model.id)
    else
      result.success = false
      result[:errors] = model.errors
    end

    result
  end

  def album_is_full
    ServiceResult.new.tap do |result|
      result.success = false
      result[:errors] = {album: ["Album is full"]}
    end
  end

  def invalid_album
    ServiceResult.new.tap do |result|
      result.success = false
      result[:errors] = {album: ["No album exists with id #{album_id}"]}
    end
  end

  def create_content_list_entry(model_id)
    AddMediaToAlbumService.invoke(album_id: album_id, media_type: media_class.name, media_type_id: model_id)
  end

  def media_class
    options.fetch(:media_type, Photo)
  end

  def media_class_sym
    media_class.name.downcase.to_sym
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

  def attributes
    @attributes ||= options.fetch(media_class_sym, {})
  end

end
