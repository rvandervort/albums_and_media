class CreateMultiplePhotosService < ServiceBase
  def execute!
    result = ServiceResult.new

    validate_and_build_photos

    if all_attributes_are_valid?
      photo_records.each(&:save)

      result.success = true
      result[:photos] = photo_records

      AverageDateUpdaterService.invoke(album_id: album_id)
    else
      result.success = false
      result[:attributes_and_errors] = photo_attribute_set
    end

    result
  end

  private

  attr_accessor :photo_records

  def validate_and_build_photos
    @photo_records = []
    @all_records_valid = true

    photo_attribute_set.each do |attributes|
      if !attributes[:album_id].blank? && attributes[:album_id] != album_id
        attributes[:errors] = {album: "All records must be for album #{album_id}"}
        @all_records_valid = false
      else
        photo = Photo.new(params_with_whitelist(attributes))
        @photo_records << photo

        unless photo.valid?
          attributes[:errors] = photo.errors
          @all_records_valid = false
        end
      end
    end
  end

  def all_attributes_are_valid?
    @all_records_valid == true
  end

  def photo_attribute_set
    @photo_attribute_set ||= options.fetch(:photos, [])
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
end
