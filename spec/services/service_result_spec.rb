require 'rails_helper'

RSpec.describe ServiceResult do
  describe "properties" do
    it "allows settings/getting properties" do
      subject[:my_property] = "milkshake"
      expect(subject[:my_property]).to eq("milkshake")
    end
  end

  describe "#errors" do
    let(:error_list) { {base: ["err 1", "err 2"]} }

    it "returns the list of errors in the property hash" do
      subject[:errors] =  error_list
      expect(subject.errors).to eq(error_list)
    end
  end
end
