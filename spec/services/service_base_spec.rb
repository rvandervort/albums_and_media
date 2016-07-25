require 'rails_helper'

class ServiceWithoutExecute < ServiceBase
end

class ServiceWithExecute < ServiceBase
  def execute!
    "Diamonds are #{options[:name]}"
  end
end

RSpec.describe ServiceBase do
  describe "##invoke" do
    it "executes a new instance of the service" do
      expect(ServiceWithExecute.invoke(name: "forever")).to eq("Diamonds are forever")
    end
  end

  describe "#execute!" do
    it "raises NotImplementedError if the method is not overridden" do
      service = ServiceWithoutExecute.new(name: "forever")
      expect { service.execute! }.to raise_error(NotImplementedError)
    end
  end
end
