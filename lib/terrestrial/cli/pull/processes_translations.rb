module Terrestrial
  module Cli
    class Pull < Command
      class ProcessesTranslations
        def self.run(translations, local_strings, platform)
          new(translations, local_strings, platform).run
        end

        def initialize(translations, local_strings, platform)
          @translations = translations
          @local_strings = local_strings
          @platform = platform
        end

        def run
          case platform
          when "ios"
            process_ios
          when "android"
            process_android
          else
            raise "Unknown platform"
          end
        end

        def process_android
          translations
            .reject {|entry| entry["translation"].nil? || entry["translation"].empty? }
            .map    {|entry| TranslatedString.new(entry["translation"], entry["id"], false) }
        end

        def process_ios
          local_strings.map do |local_string|
            match = find_translation_for_id(local_string["identifier"])
            if match
              TranslatedString.new(match["translation"], match["id"], false)
            else
              TranslatedString.new(local_string["string"], local_string["identifier"], true)
            end
          end
        end

        def find_translation_for_id(id)
          translations.detect {|t| t["id"] == id }
        end

        private

        def translations
          @translations
        end

        def local_strings
          @local_strings
        end

        def platform
          @platform
        end
      end
    end
  end
end
