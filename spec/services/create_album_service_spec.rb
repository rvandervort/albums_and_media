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
  end
end
