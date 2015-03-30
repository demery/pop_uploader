module PopUploader
  class CommandsTasks # :nodoc:
    attr_reader :argv

    HEADER_YAML = File.expand_path('../../../config/headers.yml', __FILE__)

    HELP_MESSAGE = <<-EOT
Usage: pop COMMAND [ARGS]

  pop upload XLSX_FILE
             Upload file images listed in XLSX_FILE using supplied metadata

  pop delete PHOTO_ID [...]
             Given the list of Flickr PHOTO_IDs, delete images from Flickr

EOT

    COMMAND_WHITELIST = %w(upload delete version help)

    def initialize(argv)
      @argv = argv
    end

    def run_command! command
      PopUploader.configure!
      command = parse_command(command)
      if COMMAND_WHITELIST.include?(command)
        send(command)
      else
        write_error_message(command)
      end
    end

    def upload
      xlsx_file = argv.shift
      @client ||= connect_to_flickr!
      Uploader.new(xlsx_file).upload_images @client
    end

    def delete
      PopUploader.exit_with_error "Please provide at least one PHOTO_ID" unless argv.size > 0
      @client ||= connect_to_flickr!
      while (photo_id = argv.shift) do
        begin
          @client.delete(photo_id).methods
        rescue Exception => ex
          PopUploader.exit_with_error "Whoopsie! Could not delete photo with id '#{photo_id}'\nReason: #{ex}"
        end
      end
    end

    def help
      write_help_message
    end

    def version
      puts "pop v#{VERSION}"
    end

    private

    def connect_to_flickr!
      begin
        FlickrClient.connect!
      rescue PopException => ex
        PopUploader.exit_with_error "Could not connect to Flickr: #{ex}"
      end
    end

    def write_help_message
      puts HELP_MESSAGE
    end

    def write_error_message command
      puts "Error: Command '#{command}' not recognized"
      write_help_message
      exit 1
    end

    def parse_command command
      case command
      when '--version', '-v'
        'version'
      when '--help', '-h'
        'help'
      else
        command
      end
    end
  end
end
