require 'spec_helper'

module PopUploader
  describe Uploader do

    before(:example) { PopUploader.configure! }

    context "creation" do
      it "creates a Uploader" do
        expect(valid_uploader).to be_a Uploader
      end
    end

    context "uploading" do
      it "uploads a images to flickr"
    end
  end
end
