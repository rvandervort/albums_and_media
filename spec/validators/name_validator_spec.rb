require 'rails_helper'
require 'ostruct'


RSpec.describe NameValidator do
  let(:model) { OpenStruct.new({name: "", errors: nil}) }

  before :each do
    model.errors = ActiveModel::Errors.new(model)
  end

  describe "#validate" do
    it "adds an error if the name is nil" do
      model.name = nil
      subject.validate(model)
      expect(model.errors[:name]).to match_array(["Name cannot be blank"])
    end

    it "adds an error if the name is blank" do
      model.name = ""
      subject.validate(model)
      expect(model.errors[:name]).to match_array(["Name cannot be blank"])
    end
  end
end
