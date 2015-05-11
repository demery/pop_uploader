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
      tag_url copy_call_number
    end

    def tag_url tag_string
      "#{pop_user_url}/tags/#{tag_string.normalize}"
    end
    def identifications
      [ donors, recipients, sellers, selling_agents, buyers, owners ].flatten
    end

    def donors
      id_list 'donor', PopUploader.header_config.donor_headers
    end

    def recipients
      id_list 'recipient', PopUploader.header_config.recipient_headers
    end

    def sellers
      id_list 'seller', PopUploader.header_config.seller_headers
    end

    def selling_agents
      id_list 'selling agent', PopUploader.header_config.selling_agent_headers
    end

    def buyers
      id_list 'buyer', PopUploader.header_config.buyer_headers
    end

    def owners
      id_list 'owner', PopUploader.header_config.owner_headers
    end

    def others
      id_list 'other', PopUploader.header_config.otherid_headers
    end

    def identified?
      @is_identified ||= identification_headers.any? { |attr|
        v = vals attr; v && v.size > 0
      }
    end

    def identification_headers
      PopUploader.header_config.identified_name_headers + [ :id_place, :id_date ]
    end

    class Ident
      attr_accessor :name, :role
      def initialize name, role; @name = name; @role = role; end
      def to_s; "#{name}, #{role}"; end
    end

    def id_list role, attrs
      attrs.flat_map { |attr|
        vals attr
      }.map { |name|
        Ident.new name, role
      }
    end

    def identified_names?
      PopUploader.header_config.identified_name_headers.any? { |attr|
        v = vals attr; v && v.size > 0
      }
    end

    def associated_places
      @associated_places ||= vals(:evidence_place_associated).join('; ')
    end

    def associated_dates
      @associated_dates ||= vals(:evidence_date_associated).join('; ')
    end

    def associated_names
      PopUploader.header_config.associated_name_headers.flat_map { |attr|
        vals attr
      }.join('; ')
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

    def photo_title
      if identified_names?
        "#{format}: #{identifications.map(&:name).join '; '}"
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
      PopUploader.header_config.tag_headers.flat_map { |attr|
        (send(attr) || '').split('|')
      }.uniq
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
