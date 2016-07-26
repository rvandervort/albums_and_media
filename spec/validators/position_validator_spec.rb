
require 'rails_helper'
require 'ostruct'


RSpec.describe PositionValidator do
  let(:model) { OpenStruct.new({position: nil, errors: nil}) }

  before :each do
    model.errors = ActiveModel::Errors.new(model)
  end

  describe "#validate" do
    it "adds an error if the position is nil" do
      model.postion = nil
      subject.validate(model)
      expect(model.errors[:position]).to match_array(["position must be a positive integer"])
    end

    it "adds an error if the position is < 0" do
      model.postion = -1
      subject.validate(model)
      expect(model.errors[:position]).to match_array(["position must be a positive integer"])
    end
  end
end
