require 'spec_helper'
require 'pop_uploader/image_row'
require 'pop_uploader/sheet'

module PopUploader
  describe ImageRow do

    let (:image_row) { ImageRow.new valid_sheet, 2 }
    let (:row_with_optional_header) { ImageRow.new sheet_with_optional_header, 2 }

    before(:example) { PopUploader.configure! }

    context "creation" do
      it "creates a row" do
        expect(ImageRow.new valid_sheet, 2).to be_an ImageRow
      end
    end # context "creation"

    context "optional header" do
      it "has an optional header" do
        expect(sheet_with_optional_header.valid_header? :new_header).to be true
      end

      it "has responds to an optional header request with nil" do
        expect(row_with_optional_header.new_header).to be nil
      end

      it "sets an optional header value" do
        expect { row_with_optional_header.new_header = 'new data'}.not_to raise_error
      end

      it "doesn't accept a non existent header" do
        expect { image_row.not_a_header = 'value' }.to raise_error NoMethodError
      end

      it "won't set a invalid value" do
        expect { image_row.set_value :not_a_header, 'value' }.to raise_error HeaderException
      end

      it "won't return an invalid value" do
        expect { image_row.local_value :not_a_header }.to raise_error HeaderException
      end

      it "gets the optional header value" do
        row_with_optional_header.new_header = 'new data'
        expect(row_with_optional_header.new_header).to eq 'new data'
      end

      it "overrides an existing value" do
        image_row.copy_call_number = "new call number"
        expect(image_row.copy_call_number).to eq "new call number"
      end
    end

    context "privacy" do
      it "protects local_values" do
        row_with_optional_header.new_header = 'new header'
        expect { row_with_optional_header.local_values }.to raise_error NoMethodError
      end
    end

    context "fields" do
      it "has evidence_comments" do
        expect(image_row.evidence_comments).not_to be_nil
      end

      it "has file_name" do
        expect(image_row.file_name).not_to be_nil
      end
    end

  end # describe ImageRow
end # module PopUploaderxk
