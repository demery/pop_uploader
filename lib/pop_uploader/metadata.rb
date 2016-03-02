require 'erb'

module PopUploader
  class Metadata

    attr_accessor :image_hash
    def initialize data={}
      @image_hash = data
    end

    def description_erb
      File.expand_path(File.join('..', 'description.erb'), __FILE__)
    end

    def evidence?
      image_hash[:evidence_format] !~ /Title|Context/
    end

    def evidence_summary
      [ evidence_format, evidence_type ].flat_map { |s|
        present?(s) ? s : []
      }.join(', ')
    end

    # https://www.flickr.com/photos/58558794@N07
    def pop_user_url
      "https://www.flickr.com/photos/#{PopUploader.pop_flickr_userid}"
    end

    # https://www.flickr.com/photos/58558794@N07/tags/901735
    def same_book_url
      tag_url full_call_number
    end

    def tag_url tag_string
      "#{pop_user_url}/tags/#{tag_string.normalize}"
    end

    def identifications
      return @idents if @idents

      headers = PopUploader.header_config.identified_name_headers
      @idents ||= headers.flat_map do |header|
        id_list header
      end

      if viaf_links.size == 0
        # no viaf_links, nothing to do
      elsif viaf_links.size == 1 && @idents.size == 1
        @idents.first.viaf_link = viaf_links.first
      else
        $stderr.puts "WARNING: Unable match VIAF links to identifications"
      end
      @idents
    end

    def identified?
      @is_identified ||= identification_headers.any? { |attr|
        v = vals attr; v && v.size > 0
      }
    end

    def viaf_links
      @viaf_links ||= vals(:id_viaf_link)
    end

    def identification_headers
      PopUploader.header_config.identified_name_headers
    end

    class Ident
      attr_accessor :name, :role, :viaf_link
      def initialize name, role; @name = name; @role = role; end

      def to_s
        name_role  = "#{name}, #{role}"
        name_role += ", <a href=\"#{viaf_link}\">#{viaf_link}</a>" if viaf_link
        name_role
      end
    end

    def id_list id_attr
      header = PopUploader.header_config.header id_attr
      role = header.human_name
      vals(id_attr).map { |name| Ident.new name, role }
    end

    def identified_names?
      PopUploader.header_config.identified_name_headers.any? { |attr|
        v = vals attr; v && v.size > 0
      }
    end

    def format
      case evidence_format
      when /title page/i
        'Title page'
      when /context/i
        'Context image'
      else
        evidence_format
      end
    end

    # We need to print the repository before the call number.
    def full_call_number
      "#{copy_current_repository} #{copy_call_number}"
    end

    def photo_title
      if identified_names?
        "#{format}: #{identifications.map(&:name).join '; '} (#{copy_current_repository})"
      else
        "#{format} from #{copy_current_repository} #{copy_call_number}"
      end
    end

    def authors
      image_hash[:copy_author] && image_hash[:copy_author].split('|').join('; ')
    end

    def published
      [ copy_place_of_publication, copy_date_of_publication ].join ', '
    end

    def tags
      tag_values.map { |v| "\"#{v}\"" }
    end

    def tag_values
      tags = PopUploader.header_config.tag_headers.flat_map { |attr|
        (send(attr) || '').split('|')
      }.uniq
      tags.unshift full_call_number
    end

    def tag attr
      (vals attr).map { |v|  "\"#{v}\"" }
    end

    def vals attr
      (send(attr) || '').split('|')
    end

    def is_public
      1
    end

    def present? val
      val && val.size > 0
    end

    def description
      safe_level = nil
      trim_mode = "<>-"
      ERB.new(File.read(description_erb), safe_level, trim_mode).result binding
    end

    def to_h
      { title: photo_title, description: description, tags: tags.join(' '),  is_public: is_public }
    end

    def method_missing name, *args
      # If method name maps to an image_hash value, return that value.
      if image_hash.has_key? name
        image_hash[name]
      else
        super
      end
    end
  end
end
