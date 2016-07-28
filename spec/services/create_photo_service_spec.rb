require 'rails_helper'

RSpec.describe CreatePhotoService do
  describe '#execute!' do
    let(:basic_options) {{ photo: {url: "http://jpg", taken_at: Time.zone.now.to_s, name: "Photo Name", album_id: 1}}}
    let(:service) { described_class.new(options) }
    let(:result) { service.execute! }

    context "when the data passes validations" do
      let(:options) { basic_options }

      context "((test without db))" do
        before :each do
          expect_any_instance_of(Photo).to receive(:save).and_return(true)
        end

        it "returns a successful service result" do
          expect(result).to be_success
        end

        it "returns the model in the :photo service property" do
          expect(result[:photo]).to be_a(Photo)
        end
      end

      context "(( test with db ))", :db => true do
        let(:album) { Album.create(name: "Test Album", position: 1) }

        it "recalculates the average date for the album" do
          expect(AverageDateUpdaterService).to receive(:invoke).with(album_id: album.id).exactly(:once)
          options[:photo][:album_id] = album.id

          service.execute!
        end
      end
    end

    context "when the data does not pass validations" do
      let(:options) { basic_options }
      let(:errors) { {base: ["some error"]} }

      before :each do
        expect_any_instance_of(Photo).to receive(:save).and_return(false)
        expect_any_instance_of(Photo).to receive(:errors).and_return(errors)
      end

      it "returns an unsuccessful service result" do
        expect(result).not_to be_success
      end

      it "returns the validation errors in the errors service property" do
        expect(result.errors).to eq(errors)
      end
    end

    context "Misc. Verifications", :db => true do
      let(:album) { Album.create(name: "Test Album", position: 1) }
      let(:options) { basic_options }

      before :each do
        expect_any_instance_of(Photo).to receive(:album).at_least(:once).and_return(album)
        expect(album).to receive(:full?).and_return(true)
      end

      it "does not allow photos to be created for albums that are full" do
        options[:photo][:album_id] = album.id
        expect(result.errors[:album]).not_to be_nil
      end
    end
  end
end
