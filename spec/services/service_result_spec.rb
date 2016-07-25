require 'rails_helper'

RSpec.describe ServiceResult do
  describe "properties" do
    it "allows settings/getting properties" do
      subject[:my_property] = "milkshake"
      expect(subject[:my_property]).to eq("milkshake")
    end
  end

  describe "#errors" do
    it "returns the list of errors in the property hash" do
      subject[:errors] = ["err1","err2"]
      expect(subject.errors).to match_array(["err1", "err2"])
    end
  end
end
