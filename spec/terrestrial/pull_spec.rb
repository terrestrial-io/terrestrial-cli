require 'spec_helper'

describe Terrestrial::Cli::Pull do

  context "processing translations from the web" do
    it "for ios, adds missing translations into the results that get written to Localizable.strings" do
      translations = [
        { "string" => "This", "id" => "THIS", "translation" => "TÄMÄ" },
        { "string" => "That", "id" => "THAT", "translation" => "TUO" },
      ]
      local_string_registry = [
        { "string" => "This", "identifier" => "THIS" },
        { "string" => "That", "identifier" => "THAT" },
        { "string" => "Those", "identifier" => "THOSE" }
      ]

      result = Terrestrial::Cli::Pull::ProcessesTranslations.run(translations, local_string_registry, "ios")

      expect(result.count).to eq 3
      
      expect(result[0].string).to eq "TÄMÄ"
      expect(result[1].string).to eq "TUO"
      expect(result[2].string).to eq "Those"

      expect(result[0].identifier).to eq "THIS"
      expect(result[1].identifier).to eq "THAT"
      expect(result[2].identifier).to eq "THOSE"

      expect(result[0].placeholder?).to eq false
      expect(result[1].placeholder?).to eq false
      expect(result[2].placeholder?).to eq true
    end

    it "for android, does not include missing translations in each strings.xml file" do
      translations = [
        { "string" => "This", "id" => "THIS", "translation" => "TÄMÄ" },
        { "string" => "That", "id" => "THAT", "translation" => "TUO" },
      ]
      local_string_registry = [
        { "string" => "This", "identifier" => "THIS" },
        { "string" => "That", "identifier" => "THAT" },
        { "string" => "Those", "identifier" => "THOSE" }
      ]

      result = Terrestrial::Cli::Pull::ProcessesTranslations.run(translations, local_string_registry, "android")
      expect(result.count).to eq 2
      
      expect(result[0].string).to eq "TÄMÄ"
      expect(result[1].string).to eq "TUO"

      expect(result[0].identifier).to eq "THIS"
      expect(result[1].identifier).to eq "THAT"

      expect(result[0].placeholder?).to eq false
      expect(result[1].placeholder?).to eq false
    end
  end
end
