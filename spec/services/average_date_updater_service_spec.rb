require 'rails_helper'

RSpec.describe AverageDateUpdaterService do
  let(:options) { {album_id: album.id } }
  let(:old_date) { 3.days.ago.to_date }

  let(:album) { Album.create(name: "Test Album", position: 1, average_date: 3.days.ago) }
  let(:taken_at) { Time.zone.now }
  let(:photos) {}
  let(:service) { described_class.new(options) }
  let(:result) { service.execute! }


  describe '#execute', :db => true do
    before :each do
      3.times.map { |i| Photo.create(url: "http://jpg", name: "Photo #{i}", taken_at: taken_at, album_id: album.id) }
    end

    it "returns a service result with the old_date" do
      expect(result).to be_success
      expect(result[:old_date]).to eq(old_date)
    end

    it "returns a service result with the new_date" do
      expect(result[:new_date]).to eq(taken_at.to_date)
    end

    it "has updated the album with the newly calculated date" do
      expect(result).to be_success
      expect(album.reload.average_date).to eq(taken_at.to_date)
    end

    it "updates the album average_date to nil if there are no photos" do
      album.photos.destroy_all
      expect(result).to be_success
      expect(album.reload.average_date).to be_nil
    end
  end
end
