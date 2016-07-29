class CreateMultipleMediaService < ServiceBase
  def execute!
    result = validation_chain

    result.nil? ? create_media : result
  end

  private

  attr_accessor :media_records

  def album_id
    options[:album_id]
  end

  def album_exists
    if album.nil?
      ServiceResult.new.tap do |result|
        result.success = false
        result[:errors] = {album: ["Album with id #{album_id} does not exist"] }
      end
    end
  end

  def album
    @album ||= begin
                result = FetchAlbumService.invoke(id: album_id)
                result.success? ? result[:album] : nil
               end
  end

  def album_is_full
    if album.full?
      ServiceResult.new.tap do |result|
        result.success = false
        result[:errors] = {album: ["Album with id #{album_id} is full"] }
      end
    end
  end

  def album_will_be_full
    if album.will_be_full_by_adding?(media_attribute_set.count)
      ServiceResult.new.tap do |result|
        result.success = false
        result[:errors] = {album: ["Album with id #{album_id} will be full by adding these media"] }
      end
    end
  end

  def validation_chain
    [:album_exists, :album_is_full, :album_will_be_full, :build_and_validate_records].each do |validation_method|
      result = self.send(validation_method)
      unless result.nil?
        return result
      end
    end

    nil
  end

  def build_and_validate_records
    @media_records = []
    @all_records_valid = true

    media_attribute_set.each do |attrs|
      model = media_type.new(params_with_whitelist(attrs))

      @media_records << model

      unless model.valid?
        attrs[:errors] = model.errors
        @all_records_valid = false
      end
    end

    if @all_records_valid
      nil
    else
      ServiceResult.new.tap do |result|
        result.success = false
        result[:attributes_and_errors] = media_attribute_set.map { |a| {media_type_name => a} }
      end
    end
  end

  def create_media
    media_records.each do |model|
      if model.save
        AddMediaToAlbumService.invoke(album_id: album_id, media_type: plural_media_type_name, media_type_id: model.id)

      end
    end

    ServiceResult.new.tap do |result|
      result.success = true
      result[plural_media_type_name] = media_records
    end
  end

  def media_attribute_set
    @media_attribute_set ||= options.fetch(plural_media_type_name, []).map { |a| a[media_type_name] }
  end

  def params_with_whitelist(a)
    ActionController::Parameters.new(a).permit(*allowed_attributes)
  end

  def allowed_attributes
    options.fetch(:allowed_attributes, default_allowed_attributes)
  end

  def default_allowed_attributes
    [:name, :url, :description, :album_id, :taken_at]
  end

  def media_type
    options.fetch(:media_type, Photo)
  end

  def media_type_name
    media_type.name.downcase.to_sym
  end

  def plural_media_type_name
    media_type_name.to_s.pluralize.to_sym
  end
end
