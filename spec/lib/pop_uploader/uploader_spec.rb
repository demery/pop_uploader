require 'spec_helper'

module PopUploader
  describe Uploader do

    before(:example) { PopUploader.configure! }

    context "creation" do
      it "creates a Uploader" do
        expect(valid_uploader).to be_a Uploader
      end
    end

    context "missing files" do
      before(:example) { setup_dummy_jpegs }
      it "passes a valid sheet" do
        expect{ valid_uploader.validate }.not_to raise_error
      end

      it "fails when files are missing" do
        expect { missing_files_uploader.validate }.to raise_error PopException
      end

      it "finds missing files" do
        expect(missing_files_uploader.missing_files.size).to eq 110
      end

      it "finds no missing files" do
        expect(valid_uploader.missing_files.size).to eq 0
      end
    end


    context "uploading" do
      it "uploads a images to flickr"
    end
  end
end
