require 'spec_helper'
require 'fileutils'

module PopUploader
  describe Util do

    def touch *args
      args.each { |f| FileUtils.touch f }
    end


    context "max/min" do
      it "returns nil" do
        expect(Util.max nil, nil).to be nil
      end

      it "returns the not nil value" do
        expect(Util.max nil, 5).to be 5
      end

      it "returns the max value" do
        expect(Util.max 1, 5).to be 5
      end

      it "returns the min value" do
        expect(Util.min 1, 5).to be 1
      end
    end

    context "finding files" do

      let (:file_jpg) { File.join tmpdir, 'file.jpg' }
      let (:file_JPG) { File.join tmpdir, 'file.JPG' }
      let (:file_jpeg) { File.join tmpdir, 'file.jpeg' }
      let (:file_JPEG) { File.join tmpdir, 'file.JPEG' }
      let (:file_tif) { File.join tmpdir, 'file.tif' }
      let (:file_no_ext) { File.join tmpdir, 'file' }

      after(:example) {
        [ file_jpg, file_JPG, file_jpeg, file_JPEG, file_tif, file_no_ext ].each do |f|
          File.delete f if File.exists? f
        end
      }


      context "find_all_files" do

        it "finds one file file.jpg" do
          touch file_jpg
          expect(Util.find_all_files file_jpg).to eq [ file_jpg ]
        end

        it "finds one file when extension is wrong" do
          touch file_jpg
          expect(Util.find_all_files file_tif).to eq [ file_jpg ]
        end

        it "finds one file when extension is not provided" do
          touch file_jpg
          expect(Util.find_all_files file_no_ext).to eq [ file_jpg ]
        end

        it "finds a specific file" do
          touch [ file_jpg, file_jpeg ]
          expect(Util.find_all_files file_jpg).to eq [ file_jpg ]
        end

        it "is case insensitive" do
          touch [ file_JPG, file_JPEG ]
          expect(Util.find_all_files(file_no_ext).size).to eq 2
        end

        it "returns only the exact file name" do
          touch file_jpeg
          expect(Util.find_all_files(file_jpg, exts=nil)).to eq []
        end

        it "returns an alternate file name" do
          touch file_jpeg
          expect(Util.find_all_files(file_jpg)).to eq [ file_jpeg ]
        end
      end

      context "find_file" do
        it "finds one file" do
          touch file_jpeg
          expect(Util.find_file file_jpeg).to eq file_jpeg
        end

        it "raises an error when more than one file is found" do
          touch file_jpeg, file_jpg
          expect { Util.find_file file_no_ext }.to raise_error PopException
        end

        it "returns nil no file is found" do
          expect(Util.find_file file_no_ext).to be_nil
        end
      end

    end
  end
end
