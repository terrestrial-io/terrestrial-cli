require 'spec_helper'

describe Terrestrial::Cli::Init do
  before(:each) do
    mock_project_config
    mock_global_config
  end

  context "api key" do
    it "raises an error without an API key" do
      output = capture_stderr do
        expect { 
          Terrestrial::Cli.start("init")
        }.to raise_error SystemExit
      end

      expect(output).to eq(
        "No api key provided for. You can find your API key at https://mission.terrestrial.io/.\n"
      )
    end

    it "can be provided an api key as an argument" do
      expect { 
        Terrestrial::Cli.start("init", api_key: "fake_api_key")
      }.to_not raise_error
    end

    it "can be provided via the config" do
      mock_global_config do |config|
        config[:api_key] = "fake_api_key"
      end

      expect { 
        Terrestrial::Cli.start("init")
      }.to_not raise_error
    end
  end
end
