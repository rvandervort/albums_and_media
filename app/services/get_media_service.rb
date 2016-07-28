class GetMediaService < ServiceBase
  def execute!
    result = ServiceResult.new

    begin
      result[plural_media_type_name] = retrieve_assets
      result.success = result[plural_media_type_name].length > 0
    rescue Exception => e
      result.errors[:base] = [e.to_s]
      result.success = false
    end

    result
  end

  private

  def for_an_album?
    (album_id != nil)
  end

  def album_id
    options[:album_id]
  end

  def retrieve_assets
    if for_an_album?
      media_type.where("album_id = ?", album_id)
    else
      paginated_results
    end
  end

  def paginated_results
    media_type.paginate(page: page_number, per_page: records_per_page)
  end

  def page_number
    options.fetch(:page_number, 1)
  end

  def records_per_page
    10
  end

  def media_type
    options.fetch(:media_type, Photo)
  end

  def plural_media_type_name
    media_type.name.downcase.pluralize.to_sym
  end
end
