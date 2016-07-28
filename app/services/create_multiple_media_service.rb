class CreateMultipleMediaService < ServiceBase
  def execute!
    result = ServiceResult.new

    validate_and_build_media

    if all_attributes_are_valid?
      media_records.each(&:save)

      result.success = true
      result[plural_media_type_name] = media_records

      AverageDateUpdaterService.invoke(album_id: album_id)
    else
      result.success = false
      result[:attributes_and_errors] = media_attribute_set
    end

    result
  end

  private

  attr_accessor :media_records

  def validate_and_build_media
    @media_records = []
    @all_records_valid = true

    media_attribute_set.each do |attributes|
      if !attributes[:album_id].blank? && attributes[:album_id] != album_id
        attributes[:errors] = {album: "All records must be for album #{album_id}"}
        @all_records_valid = false
      else
        model = media_type.new(params_with_whitelist(attributes))
        @media_records << model

        unless model.valid?
          attributes[:errors] = model.errors
          @all_records_valid = false
        end
      end
    end
  end

  def all_attributes_are_valid?
    @all_records_valid == true
  end

  def media_attribute_set
    @media_attribute_set ||= options.fetch(plural_media_type_name, [])
  end

  def params_with_whitelist(a)
    ActionController::Parameters.new(a.merge(album_id: album_id)).permit(*allowed_attributes)
  end

  def allowed_attributes
    options.fetch(:allowed_attributes, default_allowed_attributes)
  end

  def default_allowed_attributes
    [:name, :url, :description, :album_id, :taken_at]
  end

  def album_id
    options[:album_id]
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
