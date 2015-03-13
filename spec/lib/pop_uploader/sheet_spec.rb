require 'spec_helper'

module PopUploader
  describe Sheet do
    let (:fixpath) { RSpec.configuration.fixtures_path }

    let (:valid_sheet_path) { File.join fixpath, 'A_NCUploadSheet_valid.xlsx' }
    let (:valid_sheet) { Sheet.new valid_sheet_path }
    let (:sheet_with_optional_header) { Sheet.new valid_sheet_path, optional_headers: { new_header: 'new:header:text' } }

    let (:sheet_header_row_2_path) { File.join fixpath, 'A_NCUploadSheet_valid_header_in_row_2.xlsx' }
    let (:sheet_header_row_2) { Sheet.new sheet_header_row_2_path }

    let (:alt_valid_sheet_path) { File.join fixpath, 'A_NCUploadSheet_valid_alt_spacings.xlsx' }
    let (:alt_valid_sheet) { Sheet.new alt_valid_sheet_path }

    let (:invalid_sheet_path) { File.join fixpath, 'A_NCUploadSheet_bad_headers.xlsx' }
    let (:invalid_sheet) { Sheet.new invalid_sheet_path }
    let (:sheet_with_altered_header) { Sheet.new invalid_sheet_path, required_headers: { file_name: 'image title XXXX' } }
    let (:sheet_with_removed_header) { Sheet.new invalid_sheet_path, remove_headers: [ :file_name ] }

    let (:sheet_no_header_path) { File.join fixpath, 'A_NCUploadSheet_no_header.xlsx' }
    let (:sheet_no_header) { Sheet.new sheet_no_header_path }

    let (:find_row_sheet_path) { File.join fixpath, 'Find_Row_Sheet.xlsx' }
    let (:find_row_sheet) { Sheet.new find_row_sheet_path }

    let (:tmpdir) { ENV['TMPDIR'] || '/tmp' }
    let (:outputsheet) { File.join tmpdir, 'outsheet.xlsx' }
    let (:removals) { [ outputsheet ] }
    let (:cleanup) { removals.each { |x| File.delete(x) if File.exists?(x) } }

    before(:example) { PopUploader.configure! }
    after(:example) { cleanup }

    context "check headers" do

      it "reads valid headers" do
        expect { valid_sheet }.not_to raise_error
      end

      it "reads alternately valid headers" do
        expect { alt_valid_sheet }.not_to raise_error
      end

      it "fails with invalid headers" do
        expect { invalid_sheet }.to raise_error HeaderException
      end

      it "fails with no headers" do
        expect { sheet_no_header }.to raise_error HeaderException
      end

      it "reads with altered header" do
        expect { sheet_with_altered_header }.not_to raise_error
      end

      it "reads with removed header" do
        expect { sheet_with_removed_header }.not_to raise_error
      end

      it "adds an optional header" do
        expect(sheet_with_optional_header.valid_header? :new_header).to be true
      end

      it "finds header row in row 1" do
        expect(valid_sheet.header_row.row_num).to eq 1
      end

      it "finds header row in row 2" do
        expect(sheet_header_row_2.header_row.row_num).to eq 2
      end

      it "fails with no header" do
        expect { invalid_sheet }.to raise_error HeaderException
      end
    end

    context "find_row" do
      it "iterates over all rows" do
        find_row_sheet.each_row {}
        expect { |b| find_row_sheet.find_row(&b) }.to yield_successive_args(*find_row_sheet.all_rows[1..-1])
      end

      it "iterates over a subset of rows" do
        find_row_sheet.each_row {}
        expect { |b| find_row_sheet.find_row(1,2,&b) }.to yield_successive_args(*find_row_sheet.all_rows[1..2])
      end

      it "finds a row based on value" do
        row = find_row_sheet.find_row { |row| row.value(1) == 'a' }
        expect(row.row_num).to be 2
      end

      it "finds another row based on value" do
        row = find_row_sheet.find_row { |row| row.value(1) == 'ab' }
        expect(row.row_num).to be 4
      end

      it "finds a row based on regex" do
        row = find_row_sheet.find_row { |r| r.values.grep(/ba/).size > 0 }
        expect(row.row_num).to be 5
      end

    end

    context "writing a spreadsheet" do
      let(:sheet_with_new_data) {
        sheet_with_optional_header.each_row do |row|
          row.new_header = row.row_num
        end
        sheet_with_optional_header.write outputsheet
        Sheet.new outputsheet, required_headers: { new_header: 'new:header:text' }
      }

      it "writes a spreadsheet" do
        valid_sheet.write outputsheet
      end

      it "creates a sheet with new values" do
        expect { sheet_with_new_data }.not_to raise_error
        sheet_with_new_data.each_row do |row|
          expect(row.new_header).to eq row.row_num.to_s
        end
      end

    end # context "writing a spreadsheet"

  end # describe Sheet
end # module PopUploader
