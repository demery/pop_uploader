require 'yaml'

module PopUploader
  class HeaderConfig
    attr_reader :config

    REQUIRED_HEADER_LISTS = %w(
        header_definitions
        required_header_definitions
        required_values
        tag_headers
        associated_name_headers
        identified_name_headers
        owner_headers
        donor_headers
        recipient_headers
        seller_headers
        selling_agent_headers
        buyer_headers
        other_headers
    ).map(&:to_sym)

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

      # Now look at required_header_definitions and all other dependent
      # lists (like tag_headers) to make sure that those keys show up
      # the list of header_definitions
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

    def headers
      header_definitions.inject({}) { |hash,kv|
        hdr = Header.new(kv.first, kv.last)
        hash[hdr.attr] = hdr
        hash
      }
    end

    def expected_header_defs
      [
       :required_header_definitions,
       :tag_headers,
       :associated_name_headers,
       :identified_name_headers,
       :owner_headers,
       :donor_headers,
       :seller_headers,
       :selling_agent_headers,
       :buyer_headers,
       :other_headers
      ].reduce({}) { |hash,key|
        hash[key] = symify_values key; hash
      }
    end

    def required_value_headers
      symify_values :required_values
    end

    def required_header_definitions
      symify_values :required_header_definitions
    end

    def tag_headers
      symify_values :tag_headers
    end

    def associated_name_headers
      symify_values :associated_name_headers
    end

    def identified_name_headers
      symify_values :identified_name_headers
    end

    def owner_headers
      symify_values :owner_headers
    end

    def other_headers
      symify_values :other_headers
    end

    def donor_headers
      symify_values :donor_headers
    end

    def recipient_headers
      symify_values :recipient_headers
    end

    def seller_headers
      symify_values :seller_headers
    end

    def selling_agent_headers
      symify_values :selling_agent_headers
    end

    def buyer_headers
      symify_values :buyer_headers
    end

    def symify_values key
      config[key.to_sym].map(&:to_sym)
    end
  end
end
