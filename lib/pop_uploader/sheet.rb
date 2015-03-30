require 'pop_uploader/header_list'
require 'pop_uploader/pop_string'

module PopUploader

  # POP Spreadsheet representation.
  #
  # Input spreadsheet is expected to have the following headers.  Note
  # that these are accessed by symbol attributes mapped to them.
  #
  class Sheet
    attr_reader :sheet, :dir, :filename, :errors

    # Create a new PopUploader::Sheet object from file at path. On load the
    # sheet is validated to ensure that it has all expected
    # headers. The list of required headers can be altered using the
    # options hash.
    #
    # Header validation is done only during initialization.
    #
    # Options:
    #
    # :remove_headers
    #   An array of header attributes to remove from the required
    #   header list:
    #       remove_headers: [ :id_organization_seller, :id_organization_owner ]
    #
    # :required_headers
    #   A hash of extra required headers in the form
    #       required_headers: { new_header: 'new:header text', ... }
    #
    # :optional_headers
    #   A hash of headers to add as an attribute, but not to be
    #   required on load:
    #       optional_headers: [ new_header: 'new: header text' ]
    #
    # Note: Existing header attribute can be passed in the
    # required_headers hash to set new expected text for a header for
    # this sheet instance. The following will change the text expected
    # for the :id_organization_seller header.
    #
    #       id_organization_seller: 'id:institutional:seller'
    #
    # Options :remove_headers and :required_headers are applied before
    # validation.  After validation is performed :optional_headers are
    # applied.
    #
    # Optional header entries are useful for two purposes: (1) to add
    # a new column (like Flickr photo_id) for serializing to a new
    # spreadsheet; (2) to make possible the retrieval of a column that
    # may or may not be present in the spreadsheet, while avoiding
    # validation failure in the event the column isn't present.
    def initialize(path, options={})
      @filename            = File.basename path
      @dir                 = File.dirname path
      @sheet               = Roo::Spreadsheet.open path
      @sheet.default_sheet = sheet.sheets.first
      @known_headers       = HeaderList.new PopUploader.header_config.headers
      @errors              = []

      options[:remove_headers] and options[:remove_headers].each do |attr|
        @known_headers.remove attr
      end

      options[:required_headers] and options[:required_headers].each do |k,v|
        @known_headers.add k, v
      end

      options[:optional_headers] and options[:optional_headers].each do |k,v|
        optional_header = true
        @known_headers.add k, v, optional_header
      end
    end

    def find_column_num attr
      return nil unless has_header? attr

      # get normalized canonical header text;
      # e.g., :id_individual_buyer => idindividualbuyer
      normal = @known_headers.header_normal attr

      # find the index in the normalized list of headers for the this sheet
      # Roo uses 1-based numbering so we add one to the array index
      headers_normalized.index(normal) + 1
    end

    def write filename
      p = Axlsx::Package.new
      wb = p.workbook

      wb.add_worksheet name: 'photos' do |wksh|
        wksh.add_row output_headers.map(&:raw)
        each_row do |row|
          wksh.add_row all_attrs.map { |attr| row.send attr }
        end
        # ugh, override auto column widths
        widths = all_attrs.map { |attr| 20 }
        wksh.column_widths(*widths)
      end
      p.serialize filename
    end

    #===========================================================================
    # Metadata
    #===========================================================================
    def absolute_dir
      File.expand_path dir
    end

    def full_path
      File.join absolute_dir, filename
    end

    def metadata
      { sheet_dir: absolute_dir, sheet_filename: filename }
    end

    #===========================================================================
    # Rows
    #===========================================================================
    def each_row
      ((header_row.row_num + 1)..sheet.last_row).each do |row_num|
        yield row row_num
      end
    end

    def find_row from_row=nil, up_to_row=nil
      # use sheet.last_row or up_to_row whichever is less
      last_row = Util.min up_to_row, sheet.last_row

      # use sheet.first_row or from_row whichever is greater
      first_row = Util.max from_row, sheet.first_row

      (first_row..last_row).each do |row_num|
        curr_row = row row_num
        return curr_row if yield curr_row
      end
      nil
    end

    def find_all_rows
      ((header_row.row_num + 1)..sheet.last_row).flat_map do |row_num|
        curr_row = row row_num
        yield(curr_row) ? curr_row : []
      end
    end

    def map skip_header=true
      start = skip_header ? (header_row.row_num + 1) : sheet.first_row
      (start..sheet.last_row).map { |row_num|
        curr_row = row row_num
        yield curr_row
      }
    end

    def all_rows
      # make sure all rows have been fetched
      (sheet.first_row..sheet.last_row).each { |i| row i }
      @row_cache.clone
    end

    def row row_num
      (@row_cache ||= [])[row_num] ||= ImageRow.new self, row_num
    end

    #===========================================================================
    # Files
    #===========================================================================

    def find_files
      each_row do |row|
        actual_path = Util.find_file row.image_file_path
        row.actual_filename = File.basename actual_path if actual_path
      end
    end

    def missing_files
      find_files
      find_all_rows { |row| ! row.actual_filename }
    end

    #===========================================================================
    # Headers
    #===========================================================================
    def output_headers
      @known_headers.headers
    end

    def all_attrs
      @known_headers.all_attrs
    end

    def valid_header? attr
      !! @known_headers.include?(attr)
    end

    def headers_normalized
      @headers_normalized ||= header_row.values.map(&:normalize)
    end

    def header_values
      header_row.values
    end

    def has_header? attr
      headers_normalized.include? @known_headers.header_normal(attr)
    end

    def header_row
      @header_row = find_row 1, 4 do |row|
        row.values.grep(/^(copy|evidence|id):/).size > 3
      end
      unless @header_row
        raise HeaderException, "Could not find header row in sheet #{filename}"
      end
      @header_row
    end

    #===========================================================================
    # Validation
    #===========================================================================
    def validate
      validate_headers
      # fail here because subsequent validation depend on headers
      fail_if_errors HeaderException, "Headers missing from #{@filename}"

      validate_files
      validate_values
      fail_if_errors PopException, "Errors encountered validating #{@filename}"
    end

    def validate_values
      each_row do |row|
        PopUploader.header_config.required_value_headers.each do |header|
          unless row.extract_value header
            add_errors "Missing value for image #{row.file_name}: #{header}"
          end
        end
      end
    end

    def validate_files
      missing_files.each do |file|
        add_errors "Missing expected file #{file}"
      end
    end

    def validate_headers
      unexpected_headers
      missing_headers
    end

    def unexpected_headers
      unexpecteds = header_row.values.find_all { |raw|
        ! @known_headers.all_normalized.include? raw.normalize
      }
      unless unexpecteds.empty?
        $stderr.puts  "WARNING: Unexpected headers found in `#{filename}': #{unexpecteds.map(&:quote).join '; '}."
      end
    end

    def missing_headers
      @known_headers.headers.each do |hdr|
        unless hdr.optional? || headers_normalized.include?(hdr.normal)
          STDERR.puts "#{hdr.inspect}: #{hdr.optional?}"
          add_errors "Expected header not found #{hdr.raw}"
        end
      end
    end

    def add_errors *errs
      ((@errors ||= [])  << errs).flatten!
    end

    def fail_if_errors err_class, head_msg
      if @errors and @errors.size > 0
        (msg = []) << head_msg << @errors
        raise err_class, msg.join($/)
      end
    end

    def ==(o)
      o.class == self.class &&
        o.full_path == full_path
    end
  end
end
