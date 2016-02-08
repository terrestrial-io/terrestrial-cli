require 'terrestrial/cli/pull/processes_translations'
require 'pathname'
require 'fileutils'

module Terrestrial
  module Cli
    class Pull < Command

      def run
        Config.load!
        MixpanelClient.track("cli-pull-command")

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
        write_translation_file(
          translation_file_path_for(language),
          ProcessesTranslations.run(translations, string_registry.entries, Config[:platform])
        )
      end

      def translation_file_path_for(language)
        if Config[:platform] == "ios"
          ios_translation_file_path(language)
        elsif Config[:platform] == "android"
          android_translation_file_path(language) 
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

      def android_translation_file_path(language)
        folder = Pathname.new(Config[:directory] + "/" + Config[:translation_files].first)
          .parent
          .parent
          .to_s + "/values-#{format_language_code(language)}"

        FileUtils.mkdir_p(folder)
        folder + "/strings.xml"
      end

      def write_translation_file(path, translations)
        File.open(path, "w+") do |f|
          if Config[:platform] == "ios"
            f.write "// Updated by Terrestrial #{Time.now.to_s}\n\n"
            f.write DotStringsFormatter.new(translations).format_foreign_translation
          elsif Config[:platform] == "android"
            f.write "<!-- Updated by Terrestrial #{Time.now.to_s} -->\n\n"
            f.write AndroidXmlFormatter.new(translations).format_foreign_translation
          end
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

      def string_registry
        @string_registry ||= StringRegistry.load
      end

      def web_client
        @web_client ||= Web.new
      end

      class TranslatedString < Struct.new(:string, :identifier, :placeholder?)
      end
    end
  end
end
