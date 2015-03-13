require 'roo'
require 'axlsx'
require 'flickraw'
require "pop_uploader/version"
require 'pop_uploader/util'
require 'pop_uploader/header_config'
require 'pop_uploader/pop_string'
require 'pop_uploader/exceptions'
require 'pop_uploader/flickr_client'
require 'pop_uploader/uploader'
require 'pop_uploader/metadata'
require 'pop_uploader/header'
require 'pop_uploader/header_list'
require 'pop_uploader/sheet'
require 'pop_uploader/image_row'

module PopUploader

  class << self
    def root
      File.expand_path '../..', __FILE__
    end

    def config_dir
      File.join root, 'config'
    end

    DEFAULT_HEADER_YAML = File.join(PopUploader.config_dir, 'headers.yml')

    POP_FLICKR_API_KEY       = 'POP_FLICKR_API_KEY'
    POP_FLICKR_SHARED_SECRET = 'POP_FLICKR_API_SECRET'
    POP_FLICKR_ACCESS_TOKEN  = 'POP_FLICKR_ACCESS_TOKEN'
    POP_FLICKR_ACCESS_SECRET = 'POP_FLICKR_ACCESS_SECRET'
    POP_FLICKR_USERID        = 'POP_FLICKR_USERID'

    POP_FLICKR_ATTRS = {
                    pop_flickr_api_key:       POP_FLICKR_API_KEY,
                    pop_flickr_shared_secret: POP_FLICKR_SHARED_SECRET,
                    pop_flickr_access_token:  POP_FLICKR_ACCESS_TOKEN,
                    pop_flickr_access_secret: POP_FLICKR_ACCESS_SECRET,
                    pop_flickr_userid:        POP_FLICKR_USERID
                   }


    # Options include:
    #
    #   :header_yaml_path - path to headers YAML file;
    #       default is `config/headers.yml`
    #
    # The following flickr connection and configuration values. By
    # defaul the system will check for the name environment variables.
    #
    #   :pop_flickr_api_key       => ENV['POP_FLICKR_API_KEY'],
    #   :pop_flickr_shared_secret => ENV['POP_FLICKR_SHARED_SECRET'],
    #   :pop_flickr_access_token  => ENV['POP_POP_FLICKR_ACCESS_TOKEN'],
    #   :pop_flickr_access_secret => ENV['POP_FLICKR_ACCESS_SECRET'],
    #   :pop_flickr_userid        => ENV['POP_FLICKR_USERID']
    #
    def configure! options={}
      @@config_options = options
      @@config_options[:header_yaml_path] ||= DEFAULT_HEADER_YAML
      POP_FLICKR_ATTRS.each do |key,env_var|
        @@config_options[key] = options[key] || get_or_fail(env_var)
      end
      load_header_config @@config_options[:header_yaml_path]
    end

    def get_or_fail env_var
      val = ENV[env_var]
      unless val && val.size > 0
        msg = "Missing required value; option or ENV var not set for #{env_var}"
        raise PopException, msg
      end
      val
    end

    def method_missing name, *args
      # If method name is a @@config_options hash key, return its value.
      if @@config_options.has_key? name.to_sym
        @@config_options[name.to_sym]
      else
        super
      end
    end

    def load_header_config headers_yml
      begin
        @@header_config = HeaderConfig.new headers_yml
      rescue PopException => ex
        exit_with_error "Unable to load #{headers_yml}\nReason: #{ex}"
      end
    end

    def header_config
      @@header_config
    end

  end
end
