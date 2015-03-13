require 'pop_uploader/exceptions'

module PopUploader
  class ImageRow
    attr_accessor :pop_sheet, :row_num, :actual_filename

    def initialize pop_sheet, row_num
      @pop_sheet = pop_sheet
      @row_num = row_num
    end

    def valid_header? attr
      @pop_sheet.valid_header? attr
    end

    def has_header? attr
      @pop_sheet.has_header? attr
    end

    def col_num attr
      pop_sheet.find_column_num attr
    end

    def image_file_path
      if actual_filename
        File.join(pop_sheet.dir, actual_filename)
      else
        File.join(pop_sheet.dir, file_name)
      end
    end

    # roo cell types:
    #
    #   :float
    #   :string,
    #   :date
    #   :percentage
    #   :formula
    #   :time
    #   :datetime.
    #
    def celltype attr
      pop_sheet.sheet.celltype row_num, col_num(attr)
    end

    def values
      (pop_sheet.sheet.first_column..pop_sheet.sheet.last_column).map do |col|
        # puts "col is #{col}"
        pop_sheet.sheet.cell row_num, col
      end
    end

    def extract_value attr
      return local_value attr if has_local_value? attr
      value = pop_sheet.sheet.cell row_num, col_num(attr)

      if value
        # Excel returns integer numbers as floats. Sigh.
        # Assume we have no floats and fix this
        (celltype(attr) == :float ? value.to_i : value).to_s
      else

      end
    end

    def value col_num
      pop_sheet.sheet.cell row_num, col_num
    end

    def local_values
      @local_values ||= {}
    end

    private :local_values

    def has_local_value? attr
      local_values.has_key? attr.to_sym
    end

    def local_value attr
      check_header attr
      local_values[attr.to_sym]
    end

    def check_header attr
      unless valid_header? attr
        raise HeaderException, "Not a valid header: #{attr}"
      end
      true
    end

    def set_value attr, *args
      check_header attr
      local_values[attr.to_sym] = args.join '|'
    end

    def method_missing method, *args
      if method =~ /=$/ && valid_header?(method.to_s.chomp('='))
        set_value method.to_s.chomp('='), *args
      elsif (valid_header? method)
        # Get the column number for the attribute; example:
        #
        #     :id_organization_owner => 20
        #
        extract_value method
      else
        super
      end
    end

    def data
      to_h
    end

    def ==(o)
      o.class == self.class &&
        o.row_num == row_num &&
        o.pop_sheet = pop_sheet
    end

    def to_h
      pop_sheet.all_attrs.inject({}) { |hash, key|
        hash[key] = send key; hash
      }.merge(pop_sheet.metadata)
    end

    def to_s
      "#{file_name}: row #{row_num}"
    end
  end # class ImageRow
end # module PopUploader
