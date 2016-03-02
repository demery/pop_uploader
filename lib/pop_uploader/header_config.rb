require 'yaml'

module PopUploader
  class HeaderConfig
    attr_reader :config

    REQUIRED_HEADER_LISTS = %w(
        header_definitions
        required_values
        tag_headers
        identified_name_headers
    ).map(&:to_sym)

    # Required headers definitions are those headers that must be defined for
    # the pop uploader to work.
    REQUIRED_HEADER_DEFINITIONS = %w(
      file_name
      copy_call_number
      copy_current_repository
      copy_place_of_publication
      copy_date_of_publication
    ).map &:to_sym

    def initialize header_yml
      @header_yml = header_yml
      @config = YAML.load File.read(@header_yml)
      validate_header_defs
    end

    def validate_header_defs
      # first make sure all the sections we need are listed in
      # headers.yml
      missing_sections = REQUIRED_HEADER_LISTS.find_all { |k|
        ! config.has_key? k
      }
      unless missing_sections.empty?
        raise "Header config '#{@header_yml} is missing these lists: #{missing_sections}"
      end

      # Now look at REQUIRED_HEADER_DEFINITIONS and all other dependent lists (like
      # tag_headers) to make sure that those keys show up the list of
      # header_definitions
      missing_header_defs = {}
      expected_header_defs.each { |k,v|
        missing = v.find_all { |h|
          header_definitions[h].nil?
        }
        missing_header_defs[k] = missing unless missing.empty?
      }
      unless missing_header_defs.empty?
        msg = missing_header_defs.map { |k,v|
          "\tSection #{k}: #{v.join ', '}"
        }
        msg.unshift "The following expected header definitions were not found:"
        raise PopException, msg.join("\n")
      end
    end

    def header_definitions
      config[:header_definitions]
    end

    def header attr
      headers[attr] or
        raise "Unknown header attribute '#{attr}' (known: #{header_attrs})"
    end

    def headers
      @headers ||= header_definitions.inject({}) { |hash,kv|
        hdr = Header.new(kv.first, kv.last)
        hash[hdr.attr] = hdr
        hash
      }
    end

    def header_attrs
      headers.keys
    end

    def expected_header_defs
      (hdrs ||= {})[:required_header_definitions] = REQUIRED_HEADER_DEFINITIONS
      [
       :tag_headers,
       :identified_name_headers,
       :required_values
      ].reduce(hdrs) { |hash,key|
        hash[key] = symify_values key; hash
      }
    end

    def required_value_headers
      symify_values :required_values
    end

    def tag_headers
      symify_values :tag_headers
    end

    def identified_name_headers
      symify_values :identified_name_headers
    end

    def symify_values key
      config[key.to_sym].map(&:to_sym)
    end
  end
end
