class FetchMediaService < ServiceBase
  def execute!
    result = ServiceResult.new

    begin
      result[media_type_name] = media_type.find(id)
      result.success = true
    rescue ActiveRecord::RecordNotFound => arnf
      result.errors[:base] = ["#{media_type.name} with id #{id} not found"]
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

  def media_type
    options.fetch(:media_type, Photo)
  end

  def media_type_name
    media_type.name.downcase.to_sym
  end
end
