class GetAlbumsService < ServiceBase
  def execute!
    result = ServiceResult.new

    begin
      result[:albums] =  paginated_results
      result.success = true
    rescue Exception => e
      result.errors[:base] = [e.to_s]
      result.success = false
    end

    result
  end

  private

  def paginated_results
    Album.all.paginate(page: page_number, per_page: records_per_page)
  end

  def page_number
    options.fetch(:page_number, 1)
  end

  def records_per_page
    10
  end
end
