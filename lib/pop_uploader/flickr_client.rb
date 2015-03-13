module PopUploader
  class FlickrClient
    attr_accessor :api_key, :shared_secret, :access_token, :access_secret, :userid


    class << self
      def connect! options={}
        creds                 = {}
        creds[:api_key]       = PopUploader.pop_flickr_api_key
        creds[:shared_secret] = PopUploader.pop_flickr_shared_secret
        creds[:access_token]  = PopUploader.pop_flickr_access_token
        creds[:access_secret] = PopUploader.pop_flickr_access_secret

        client                = FlickrClient.new(creds)
        client.connect
        client
      end

    end

    # Create a new FlickrClient; credentials should be a hash of
    # :api_key, :shared_secret, :access_token, :access_secret, and
    # :user_id. The last of these is not require, but can be handy for
    # constructing user-specific URLs
    #
    def initialize credentials={}
      credentials.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def connect
      FlickRaw.api_key       = api_key
      FlickRaw.shared_secret = shared_secret
      flickr.access_token    = access_token
      flickr.access_secret   = access_secret
      @login                 = flickr.test.login
    end

    def to_s
      "FlickrClient api_key=#{api_key && '[HIDDEN]'}..." +
        "; shared_secret=#{shared_secret && '[HIDDEN]'}..." +
        "; access_token=#{access_token && '[HIDDEN]'}..." +
        "; access_secret=#{access_secret && '[HIDDEN]'}..."
    end

    # Upload file to Flickr with provided metadata and return the
    # Flickr ID of the new photo. Metadata is hash containing any of
    # the allowed Flickr upload arguments (see
    # https://www.flickr.com/services/api/upload.api.html):
    #
    # :title (optional)
    #   The title of the photo.
    #
    # :description (optional)
    #   A description of the photo. May contain some limited HTML.
    #
    # :tags (optional)
    #   A space-seperated list of tags to apply to the photo.
    #
    # :is_public, :is_friend, :is_family (optional)
    #   Set to 0 for no, 1 for yes. Specifies who can view the photo.
    #
    # :safety_level (optional)
    #   Set to 1 for Safe, 2 for Moderate, or 3 for Restricted.
    #
    # :content_type (optional)
    #   Set to 1 for Photo, 2 for Screenshot, or 3 for Other.
    #
    # :hidden (optional)
    #   Set to 1 to keep the photo in global search results, 2 to hide
    #   from public searches.
    #
    #
    def upload file, metadata={}
      flickr.upload_photo file, metadata
    end

    # photo_id (Required)
    #   The id of the photo to delete.
    #
    # ERROR CODES
    # ===========
    #
    # 1: Photo not found
    #   The photo id was not the id of a photo belonging to the
    #   calling user.
    #
    # 95: SSL is required
    #   SSL is required to access the Flickr API.
    #
    # 96: Invalid signature
    #   The passed signature was invalid.
    #
    # 97: Missing signature
    #   The call required signing but no signature was sent.
    #
    # 98: Login failed / Invalid auth token
    #   The login details or auth token passed were invalid.
    #
    # 99: User not logged in / Insufficient permissions
    #   The method requires user authentication but the user was not
    #   logged in, or the authenticated method call did not have the
    #   required permissions.
    #
    # 100: Invalid API Key
    #   The API key passed was not valid or has expired.
    #
    # 105: Service currently unavailable
    #   The requested service is temporarily unavailable.
    #
    # 106: Write operation failed
    #   The requested operation failed due to a temporary issue.
    #
    # 111: Format "xxx" not found
    #   The requested response format was not found.
    #
    # 112: Method "xxx" not found
    #   The requested method was not found.
    #
    # 114: Invalid SOAP envelope
    #   The SOAP envelope send in the request could not be parsed.
    #
    # 115: Invalid XML-RPC Method Call
    #   The XML-RPC request document could not be parsed.
    #
    # 116: Bad URL found
    #   One or more arguments contained a URL that has been used for
    #   abuse on Flickr.
    #
    def delete photo_id
      begin
        flickr.photos.delete(photo_id: photo_id)
      rescue
        raise PopException, $!.to_s
      end
      puts "Deleted photo with ID: #{photo_id}"
    end
  end
end
