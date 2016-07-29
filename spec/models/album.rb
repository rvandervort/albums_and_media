require 'rails_helper'

RSpec.describe Album do
  it "has a maximum media count" do
    expect(described_class.max_media).to be_a(Fixnum)
  end

  describe "#current_media_count" do
    it "returns the sum of the photos and videos counts" do
      expect(subject).to receive(:photos_count).and_return(1100)
      expect(subject).to receive(:videos_count).and_return(23)

      expect(subject.current_media_count).to eq(1123)
    end
  end

  describe "#full?" do
    it "returns true if the current_media_count is at least as much as the maximum" do
      expect(subject).to receive(:current_media_count).and_return(described_class.max_media)
      expect(subject.full?).to be_truthy
    end

    it "returns false if the current_media_count is less than the maximum" do
      expect(subject).to receive(:current_media_count).and_return(described_class.max_media - 1)
      expect(subject.full?).to be_falsey
    end
  end


  describe '#will_be_full_by_adding?' do
    it "returns true if the sum of current and new media counts is greater than the max" do
      expect(subject).to receive(:current_media_count).and_return(described_class.max_media - 2)
      expect(subject.will_be_full_by_adding?(3)).to be_truthy
    end

    it "returns false if the sum of current and new media counts is greater than the max" do
      expect(subject).to receive(:current_media_count).and_return(described_class.max_media - 2)
      expect(subject.will_be_full_by_adding?(1)).to be_falsey
    end
  end
end
