require 'fileutils'

module PopUploader
  module GlobalHelpers
    def self.included base
      attr_accessor :removals

      base.let(:tmpdir) { Dir.tmpdir }
      base.let(:fixpath) { RSpec.configuration.fixtures_path }
      base.let(:source_jpeg) { File.join fixpath, 'AP7_F8542p_1773_1.jpg' }
      base.let(:dummy_jpegs) {
        %w( AP7_F8542p_1773_2.jpg
            AP7_F8542p_1773_3.jpg
            AP7_F8542p_1773_4.jpg
            AP7_F8542p_1773_5.jpg
            AP7_F8542p_1773_6.jpg
            AP7_F8542p_1773_7.jpg
            AP7_F8542p_1773_8.jpg
          ).map { |dummy| File.join fixpath, dummy }
      }

      base.let(:sheet_base_name)            { 'pop_test_sheet' }
      base.let(:valid_sheet_path)           { File.join fixpath, "#{sheet_base_name}_valid.xlsx"}
      base.let(:sheet_missing_files_path)   { File.join fixpath, "#{sheet_base_name}_missing_files.xlsx"}
      base.let(:sheet_header_row_2_path)    { File.join fixpath, "#{sheet_base_name}_header_in_row_2.xlsx" }
      base.let(:alt_valid_sheet_path)       { File.join fixpath, "#{sheet_base_name}_valid_alt_spacings.xlsx"}
      base.let(:invalid_sheet_path)         { File.join fixpath, "#{sheet_base_name}_bad_headers.xlsx"}
      base.let(:sheet_no_header_path)       { File.join fixpath, "#{sheet_base_name}_no_header.xlsx"}
      base.let(:sheet_missing_values_path)  { File.join fixpath, "#{sheet_base_name}_missing_values.xlsx"}
      base.let(:find_row_sheet_path)        { File.join fixpath, 'Find_Row_Sheet.xlsx' }
      base.let(:outputsheet)                { File.join tmpdir, 'outsheet.xlsx' }


      base.let(:valid_sheet)                { Sheet.new valid_sheet_path }
      base.let(:sheet_with_optional_header) { Sheet.new valid_sheet_path, optional_headers: { new_header: 'new:header:text' } }
      base.let(:sheet_missing_files)        { Sheet.new sheet_missing_files_path }
      base.let(:sheet_header_row_2)         { Sheet.new sheet_header_row_2_path }
      base.let(:alt_valid_sheet)            { Sheet.new alt_valid_sheet_path }
      base.let(:invalid_sheet)              { Sheet.new invalid_sheet_path }
      base.let(:sheet_no_header)            { Sheet.new sheet_no_header_path }
      base.let(:sheet_missing_values)       { Sheet.new sheet_missing_values_path }
      base.let(:sheet_with_altered_header)  { Sheet.new invalid_sheet_path, required_headers: { file_name: 'image file name XXX' } }
      base.let(:sheet_with_removed_header)  { Sheet.new invalid_sheet_path, remove_headers: [ :file_name ] }
      base.let(:find_row_sheet)             { Sheet.new find_row_sheet_path }

      base.let(:valid_uploader)             { Uploader.new valid_sheet_path }
      base.let(:missing_files_uploader)     { Uploader.new sheet_missing_files_path }

      base.let(:cleanup)                    { removals.each { |f| File.delete(f) if File.exists?(f) } }

      base.before(:example)                 { add_removals outputsheet; add_removals dummy_jpegs }
      base.before(:example)                 { setup_dummy_jpegs }
      base.after(:example)                  { cleanup }

      def add_removals *paths
        (@@removals ||= []) << paths
      end

      def removals
        @@removals.flatten
      end

      def setup_dummy_jpegs
        dummy_jpegs.each { |new| symlink source_jpeg, new }
      end

      def symlink old, new
        begin
          File.symlink old, new
        rescue NotImplementedError
          FileUtils.cp old, new
        rescue Errno::EEXIST
          # ugh, who knows why these files exist
        end
      end
    end
  end
end
