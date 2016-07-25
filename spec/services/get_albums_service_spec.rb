require 'rails_helper'

RSpec.describe GetAlbumsService do
  describe "#execute!" do
    let(:options) { Hash.new }
    let(:result) { described_class.new(options).execute! }

    it "returns an instance of ServiceResult" do
      expect(result).to be_a(ServiceResult)
    end

    it "returns an unsuccessful result if the page number was invalid" do
      options[:page_number] = "abc"
      expect(result.success?).to be_falsey
    end

    it "returns a successful result if the page number was valid" do
      options[:page_number] = "1"
      expect(result.success?).to be_truthy
    end

    it "returns an Album::ActiveRecord_Relation in the :albums property" do
      options[:page_number] = "1"
      expect(result[:albums]).to be_a(Album::ActiveRecord_Relation)
    end
  end
end
