module PopUploader
  class Header
    attr_accessor :attr, :raw, :optional

    def initialize(attr, raw, optional=false)
      @attr = attr
      @raw = raw
      @optional = optional
    end

    def normal
      @raw.downcase.gsub /\W+/, ''
    end

    def optional?
      !!@optional
    end

    def human_name
      (raw.split(/:/, 2)[1] || '').strip.capitalize
    end

    def to_s
      raw
    end
  end
end
