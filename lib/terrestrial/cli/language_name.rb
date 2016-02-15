module Terrestrial
  module Cli
    module LanguageName

      LANGUAGES = {
        "af" => "Afrikaans",
        "ar" => "Arabic",
        "eu" => "Basque",
        "be" => "Belarusian",
        "bg" => "Bulgarian",
        "ca" => "Catalan",
        "cs" => "Czech",
        "da" => "Danish",
        "nl" => "Dutch",
        "en" => "English",
        "et" => "Estonian",
        "fo" => "Faroese",
        "fi" => "Finnish",
        "fr" => "French",
        "de" => "German",
        "el" => "Greek",
        "he" => "Hebrew",
        "is" => "Icelandic",
        "id" => "Indonesian",
        "it" => "Italian",
        "ja" => "Japanese",
        "ko" => "Korean",
        "lv" => "Latvian",
        "lt" => "Lithuanian",
        "no" => "Norwegian",
        "pl" => "Polish",
        "pt" => "Portuguese",
        "ro" => "Romanian",
        "ru" => "Russian",
        "sr" => "SerboCroatian",
        "sk" => "Slovak",
        "sl" => "Slovenian",
        "es" => "Spanish",
        "sv" => "Swedish",
        "th" => "Thai",
        "tr" => "Turkish",
        "uk" => "Ukrainian",
        "vi" => "Vietnamese",
        "zh" => "ChineseSimplified",
        "zh-tw" => "ChineseTraditional",
        "hu" => "Hungarian"
      }

      def initialize(language_code)
        @code = language_code
      end
     
      def human_readable_name
        LANGUAGES.fetch(code) { abort "Unkown language '#{code}' encountered." }
      end

      private

      def code
        @code
      end
    end
  end
end
