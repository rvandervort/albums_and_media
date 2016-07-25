class ServiceResult
  attr_writer :success

  def initialize
    @success = false
    @properties = Hash.new
    @properties[:errors] = []
  end

  def success?
    @success
  end

  def errors
    @properties[:errors]
  end

  def [](key)
    @properties[key]
  end

  def []=(key, value)
    @properties[key] = value
  end
end
