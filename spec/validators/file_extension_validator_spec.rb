require 'rails_helper'
require 'ostruct'

RSpec.describe FileExtensionValidator do
  let(:options) { {fields: [:url], extensions: ["jpg", "jpeg"]} }
  let(:subject) { described_class.new(options) }

  let(:record) { OpenStruct.new(url: nil, errors: nil) }
  
  describe '#validate' do
    before :each do
      record.errors = ActiveModel::Errors.new(record)
    end

    it "provides an error if the field value is empty" do
      subject.validate(record)
      expect(record.errors[:url]).not_to be_empty
    end

    it "provides an error if the field value doesn't match any of the required extensions" do
      record.url = "http://host.com/doesnt/match.bash"
      subject.validate(record)
      expect(record.errors[:url]).not_to be_empty
    end

    it "provides an error, if the extension is in the middle, not the end" do
      record.url = "http://host.com/jpg/match.bash"
      subject.validate(record)
      expect(record.errors[:url]).not_to be_empty
    end


    it "provides no errors if the field value matches at least one of the extensions" do
      options[:extensions].each do |extension|
        record.url = "http://host.com/path/file.#{extension}"
        subject.validate(record)
        expect(record.errors[:url]).to be_empty
      end
    end
  end
end
