require 'spec_helper'

describe Terrestrial::Cli::Init do
  before(:each) do
    mock_project_config do |config|
      config[:directory] = "/path/to/project"
    end
    mock_global_config
    mock_web(:create_app) do |response|
      allow(response).to receive(:body).and_return({ "data" => Hash.new })
    end

    allow(Terrestrial::Cli::DetectsProjectType).to receive(:run).and_return("ios")
    allow(Dir).to receive(:[]).with("/path/to/project/**/*.strings").and_return([])
    Terrestrial::Config.load!
  end

  around(:each) do |example|
    # Don't want to see confirmation messages
    capture_stdout example.to_proc
  end

  context "arguments" do
    it "raises an error without an API key" do
      output = capture_stderr do
        expect { 
          Terrestrial::Cli::Init.run
        }.to raise_error SystemExit
      end

      expect(output).to eq(
        "No api key provided. You can find your API key at https://mission.terrestrial.io/.\n"
      )
    end

    it "will raise an error without a project ID" do
      output = capture_stderr do
        expect { 
          Terrestrial::Cli::Init.run(api_key: "fake_api_key")
        }.to raise_error SystemExit
      end

      expect(output).to eq(
        "No project ID provided. Terrestrial needs to know which project this app belongs to.\n" +
        "Visit https://mission.terrestrial.io to find your project ID.\n"
      )
    end

    it "can be provided an api key via the config" do
      mock_global_config do |config|
        config[:api_key] = "fake_api_key"
      end

      expect { 
        Terrestrial::Cli::Init.run(project_id: 1)
      }.to_not raise_error
    end
  end

  context "intialization" do
    it "creates the app under the given project" do
      api_key = "fake_api_key"
      response = object_double(Terrestrial::Web::Response.new(any_args), 
        :body => {
          "data" => { "id" => 123 }
        },
        :success? => true
      )
      client = object_double(Terrestrial::Web.new(api_key))

      allow(Terrestrial::Cli::DetectsProjectType).to receive(:run)
        .and_return("ios")

      expect(Terrestrial::Web).to receive(:new)
        .with(api_key)
        .and_return(client)

      expect(client).to receive(:create_app)
        .with(1, "ios")
        .and_return(response)

      Terrestrial::Cli::Init.run(project_id: 1, api_key: api_key)
    end

    it "creates a terrestrial.yml file and updates global config" do
      mock_web(:create_app) do |response| 
        allow(response).to receive(:body).and_return({
          "data" => { "id" => 123, name: nil, "platform" => "ios" }
        })
      end 

      expect(Terrestrial::Config).to receive(:load).with({})
      expect(Terrestrial::Config).to receive(:load).with(app_id: 123, platform: "ios", project_id: 1, api_key: "fake_api_key", translation_files: [])
      expect(Terrestrial::Config).to receive(:update_project_config)
      expect(Terrestrial::Config).to receive(:update_global_config)

      Terrestrial::Cli::Init.run(project_id: 1, api_key: "fake_api_key")
    end
  end

  it "asks the user which .strings files to start tracking" do
    files = [
      "/path/to/project/Example/en.lproj/Localizable.strings",
      "/path/to/project/Example/es.lproj/Localizable.strings"
    ]

    expect(Dir).to receive(:[]).with("/path/to/project/**/*.strings").and_return(files)

    expect(Terrestrial::Cli::FilePicker).to receive(:run)
      .with(["Example/en.lproj/Localizable.strings", "Example/es.lproj/Localizable.strings"])
      .and_return(["Example/en.lproj/Localizable.strings", "Example/es.lproj/Localizable.strings"])

    expect(Terrestrial::Config).to receive(:load).with({})
    expect(Terrestrial::Config).to receive(:load).with(app_id: nil, project_id: 1, platform: "ios", api_key: "fake_api_key", translation_files: [
      "Example/en.lproj/Localizable.strings",
      "Example/es.lproj/Localizable.strings"
    ])

    Terrestrial::Cli::Init.run(project_id: 1, api_key: "fake_api_key")
  end
end
