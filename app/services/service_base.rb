class ServiceBase
  def self.invoke(options  = {})
    self.new(options).execute!
  end

  def initialize(options = {})
    @options = options
  end

  def execute!
    raise NotImplementedError, "execute! must be overwritten in the subclass"
  end

  private

  attr_reader :options
end
