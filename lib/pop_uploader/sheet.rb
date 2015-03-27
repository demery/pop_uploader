require 'pop_uploader/header_list'
require 'pop_uploader/pop_string'

module PopUploader

  # POP Spreadsheet representation.
  #
  # Input spreadsheet is expected to have the following headers.  Note
  # that these are accessed by symbol attributes mapped to them.
  #
  class Sheet
    attr_reader :sheet, :dir, :filename

    class << self
      # the list of headers we're supposed to have
      CANONICAL_HEADERS =  {
        file_name:                               'image title',
        url_to_catalog:                          'url to catalog',
        image_type:                              'image type',
        copy_call_number:                        'copy:call number',
        copy_volume_number:                      'copy:volume number',
        copy_current_repository:                 'copy:current repository',
        copy_current_collection:                 'copy:current collection',
        copy_author:                             'copy:author',
        copy_title:                              'copy:title',
        copy_place_of_publication:               'copy:place of publication',
        copy_date_of_publication:                'copy:date of publication',
        copy_printer_publisher:                  'copy:printer/publisher',
        evidence_location_in_book:               'evidence:location in book',
        evidence_format:                         'evidence:format',
        evidence_type:                           'evidence:type',
        evidence_transcription:                  'evidence:transcription',
        evidence_individual_associated_name:     'evidence:individual associated name',
        evidence_organization_associated_name:   'evidence:organization associated name',
        evidence_family_associated_name:         'evidence:family associated name',
        evidence_date_associated:                'evidence:date associated',
        evidence_place_associated:               'evidence:place associated',
        evidence_creator_of_evidence:            'evidence:creator of evidence',
        evidence_description:                    'evidence:description',
        evidence_status:                         'evidence:status',
        id_date:                                 'id:date',
        id_place:                                'id:place',
        id_individual_owner:                     'id:individual:owner',
        id_organization_owner:                   'id:organization:owner',
        id_individual_donor:                     'id:individual:donor',
        id_organization_donor:                   'id:organization:donor',
        id_individual_recipient:                 'id:individual:recipient',
        id_organization_recipient:               'id:organization:recipient',
        id_individual_seller:                    'id:individual:seller',
        id_organization_seller:                  'id:organization:seller',
        id_individual_selling_agent:             'id:individual:selling agent',
        id_organization_selling_agent:           'id:organization:selling agent',
        id_individual_buyer:                     'id:individual:buyer',
        id_organization_buyer:                   'id:organization:buyer',
        comments:                                'comments'
      }

      # an array of all canonical headers as normalized strings
      CANONICAL_NORMALS = CANONICAL_HEADERS.values.map(&:normalize)

      def canonical_headers
        # return a deep copy of the hash
        CANONICAL_HEADERS.inject({}) { |hash, kv|
          hdr = Header.new(kv.first, kv.last)
          hash[hdr.attr] = hdr
          hash
        }
      end

    end

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

      options[:remove_headers] and options[:remove_headers].each do |attr|
        @known_headers.remove attr
      end

      options[:required_headers] and options[:required_headers].each do |k,v|
        @known_headers.add k, v
      end

      validate

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
      if @errors and @errors.size > 0
        (msg ||= []) << "ERROR: Headers missing from #{filename}" << @errors
        raise HeaderException, msg.join($/)
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
        unless headers_normalized.include?(hdr.normal)
          (@errors ||= []) << "Expected header not found #{hdr.raw}"
        end
      end
    end

    def ==(o)
      o.class == self.class &&
        o.full_path == full_path
    end
  end
end
