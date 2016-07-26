require 'rails_helper'

RSpec.describe CreateAlbumService do
  describe "#execute!" do
    let(:basic_options) { {album: {}} }

    let(:service) { described_class.new(options) }
    let(:result) { service.execute! }

    context "when the data passes validations" do
      let(:options) { basic_options.merge({album: {name: "Test Album"}}) }
      before :each do
        expect_any_instance_of(Album).to receive(:save).and_return(true)
      end

      it "returns a successful service result" do
        expect(result.success?).to be_truthy
      end

      it "returns the model in the :album service property" do
        expect(result[:album]).to be_a(Album)
      end
    end

    context "when the data does not pass validations" do
      let(:options) { basic_options.merge({album: {name: ""}}) }

      before :each do
        expect_any_instance_of(Album).to receive(:save).and_return(false)
      end

      it "returns an unsuccessful service result" do
        expect(result.success?).to be_falsey
      end

      it "returns the validation errors in the errors service property" do
        expect(result.errors).to be_a(ActiveModel::Errors)
      end
    end

    describe "positioning logic", :db => true do
      let(:options) { basic_options.merge({album: {name: "Test Album"}}) }
      
      it "positions the album at the end, when no :position is supplied" do
        3.times do |i|
          Album.create(name: "Album #{i}", position: i)
        end

        expect(result[:album].position).to eq(3)
      end
      
      it "positions the album and shifts others albums, when the :position is supplied" do
        albums = 3.times.map { |i| Album.create(name: "Album #{i}", position: i) }

        options[:album][:position] = "1"
        expect(result[:album].position).to eq(1)

        expect(albums[0].reload.position).to eq(0)
        expect(albums[1].reload.position).to eq(2)
        expect(albums[2].reload.position).to eq(3)
      end
    end
  end
end
