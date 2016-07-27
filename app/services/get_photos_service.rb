class GetPhotosService < ServiceBase
  def execute!
    ServiceResult.new.tap do |result|
      result[:photos] = retrieve_photos
      result.success = true
    end
  end

  private

  def for_an_album?
    (album_id != nil)
  end

  def album_id
    options[:album_id]
  end

  def retrieve_photos
    if for_an_album?
      Photo.where("album_id = ?", album_id)
    else
      paginated_results
    end
  end

  def paginated_results
    Photo.paginate(page: page_number, per_page: records_per_page)
  end

  def page_number
    options.fetch(:page_number, 1)
  end

  def records_per_page
    10
  end
end
