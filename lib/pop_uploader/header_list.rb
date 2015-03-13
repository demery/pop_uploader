module PopUploader
  class HeaderList
    attr_reader :header_map

    def initialize headers_hash
      @header_map = headers_hash
    end

    def all_attrs
      header_map.keys
    end

    def header attr
      header_map[attr.to_sym]
    end

    def headers
      header_map.values
    end

    def header_normal attr
      (hdr = header attr) and hdr.normal
    end

    def header_raw attr
      (hdr = header attr) and hdr.raw
    end

    def all_normalized
      @all_normalized ||= header_map.values.map(&:normal)
    end

    def add attr, header_string, optional=false
      header_map[attr.to_sym] = Header.new attr, header_string, optional
      reset_cached
    end

    def remove attr
      header_map.delete attr.to_sym
      reset_cached
    end

    def include? attr
      header_map.has_key? attr.to_sym
    end

    def reset_cached
      @all_normalized = nil
    end
  end

end
