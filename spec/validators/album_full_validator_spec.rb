require 'rails_helper' 
require 'ostruct'


RSpec.describe AlbumFullValidator do

  describe '#validate' do
    let(:album) { double(full?: true, id: 2) }
    let(:record){ OpenStruct.new(album: album, errors: nil) }
    let(:result) { subject.validate(record) }

    before :each do
      record.errors = ActiveModel::Errors.new(record)
    end

    it "adds an error to the :album list, if album is full" do
      subject.validate(record)
      expect(record.errors[:album]).not_to be_empty
      expect(record.errors[:album].first).to match(/full/)
    end

    it "doesn't add an error if the album doesn't exist" do
      album = nil
      
      subject.validate(record)
      expect(record.errors[:album]).not_to be_empty
    end

    it "doesn't add an error if the album is not full" do
      expect(album).to receive(:full?).and_return(false)
      subject.validate(record)
      expect(record.errors[:album]).to be_empty
    end
  end
end
