module PopUploader
  class Util
    class << self
      def max a, b
        return a || b unless a && b
        a > b ? a : b
      end

      def min a, b
        return a || b unless a && b
        a < b ? a : b
      end

      def find_file path, exts=%W( jpg jpeg )
        found_files = find_all_files path, exts

        if found_files.size > 1
          raise PopException, "No unique file found; found #{found_files.size} files: #{found_files.join '\n'}"
        end

        found_files.first
      end

      def find_all_files path, exts=%W( jpg jpeg )
        if File.exists? path
          [ path ]
        elsif exts && exts.size > 0
          $stderr.puts "WARNING: could not find #{path}; trying extensions: #{exts.join ',' }"
          test_path = path.sub(/\.[a-z]*$/i, '')
          Dir[test_path + '.*'].flat_map { |p|
            pattern = "#{test_path}.{#{exts.join ','}}"
            flags = File::FNM_CASEFOLD|File::FNM_EXTGLOB
            File.fnmatch(pattern, p, flags) ? p : []
          }
        else
          []
        end
      end
    end
  end
end
