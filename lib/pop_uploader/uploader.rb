require 'pop_uploader/flickr_client'
require 'fileutils'

module PopUploader
  class Uploader
    attr_reader :pop_sheet, :xlsx_file, :extra_headers

    FLICKR_ID_HEADER = { flickr_photo_id: 'flickr_photo_id' }

    TMP_DIR = Dir.tmpdir()

    def initialize xlsx_file, extra_headers={}
      @xlsx_file = xlsx_file
      @extra_headers = extra_headers
      @pop_sheet = Sheet.new(xlsx_file, optional_headers: optional_headers)
    end

    def find_files
      @pop_sheet.each_row do |row|
        actual_path = Util.find_file row.image_file_path
        row.actual_filename = File.basename actual_path if actual_path
      end
    end

    def validate
      missing = missing_files.map(&:file_name)

      unless missing.empty?
        raise PopException, "Could not find the following image files: #{missing.join('; ')}"
      end
    end

    def missing_files
      find_files
      @pop_sheet.find_all_rows { |row| ! row.actual_filename }
    end

    def optional_headers
      FLICKR_ID_HEADER.merge @extra_headers
    end

    def upload_images flickr_client, skip_validation=false
      find_files
      validate unless skip_validation
      pop_sheet.each_row do |row|
        id = upload row, flickr_client
        # capture the Flickr ID
        row.flickr_photo_id = id
      end
      resave_sheet
    end

    def resave_sheet
      tmpfile = File.join TMP_DIR, pop_sheet.filename
      pop_sheet.write tmpfile
      original = pop_sheet.full_path
      if FileUtils.compare_file original, tmpfile
        $stderr.puts "WARNING: Post-upload sheet (#{tmpfile}) identical to original (#{original})"
      else
        bak = "#{original}.bak"
        FileUtils.cp original, bak
        puts "Backed up #{original} to #{bak}"
        FileUtils.cp tmpfile, original
        puts "Rewrote #{original} with uploaded image IDs"
        File.delete tmpfile
      end
    end

    def upload image_row, flickr_client
      print "Uploading #{image_row.image_file_path}..."
      md = Metadata.new image_row.to_h
      id = flickr_client.upload image_row.image_file_path, md.to_h
      puts "done. Flickr ID #{id}"
      id
    end
  end

end
