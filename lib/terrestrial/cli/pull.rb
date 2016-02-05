require 'pathname'
require 'fileutils'

module Terrestrial
  module Cli
    class Pull < Command

      def run
        Config.load!

        fetch_translations
        languages.each do |lang, translations|
          update_translation_file(lang, translations)
        end
        print_confirmation
      end

      private

      def print_confirmation
        if languages.size == 1
          puts "Fetched latest translations for '#{languages.keys.first}'"
        elsif languages.size == 0
          puts "No translations to fetch..."
        else
          puts "Fetched latest translations for #{languages.size} languages: #{languages.keys.map {|l| "'#{l}'"}.join(", ")}."
        end
      end

      def update_translation_file(language, translations)
        write_ios_translation_file(
          translation_file_path_for(language),
          translations
            .reject {|entry| entry["translation"].nil? || entry["translation"].empty? }
            .map    {|entry| TranslatedString.new(entry["translation"], entry["id"]) }
        )
      end

      def translation_file_path_for(language)
        if Config[:platform] == "ios"
          path = ios_translation_file_path(language)

        else
          raise "Android not written yet."
        end
      end

      def ios_translation_file_path(language)
        folder = Pathname.new(Config[:directory] + "/" + Config[:translation_files].first)
          .parent
          .parent
          .to_s + "/#{format_language_code(language)}.lproj"

        FileUtils.mkdir_p(folder)
        folder + "/Localizable.strings"
      end

      def write_ios_translation_file(path, translations)
        File.open(path, "w+") do |f|
          f.write "// Updated by Terrestrial #{Time.now.to_s}\n\n"
          f.write DotStringsFormatter.new(translations).format_foreign_translation
        end
      end

      def format_language_code(language)
        lang, region = language.split("-")

        if region
          "#{lang}_#{region.upcase}"
        else
          lang
        end
      end

      def fetch_translations
        @response = web_client.get_translations(Config[:project_id], Config[:app_id])
      end

      def languages
        response.body["data"]["translations"]
      end

      def response
        @response
      end

      def web_client
        @web_client ||= Web.new
      end

      class TranslatedString < Struct.new(:string, :identifier)
      end
    end
  end
end
