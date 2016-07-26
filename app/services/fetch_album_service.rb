class FetchAlbumService < ServiceBase
  def execute!
    result = ServiceResult.new

    begin
      result[:album] = Album.find(id)
      result.success = true
    rescue ActiveRecord::RecordNotFound => arnf
      result.errors[:base] = ["Album with id #{id} not found"]
      result.success = false
    rescue Exception => e
      result.errors[:base] = [e.to_s]
      result.success = false
    end

    result
  end

  private

  def id
    options[:id]
  end
end
