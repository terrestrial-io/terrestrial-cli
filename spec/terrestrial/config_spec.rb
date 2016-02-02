require 'spec_helper'

describe Terrestrial::Config do

  after(:each) do
    Terrestrial::Config.reset!
  end

  it "can be configured with a hash" do
    Terrestrial::Config.load({"foo" => "bar"})

    expect(Terrestrial::Config["foo"]).to eq "bar"
  end

  it "sets the API url as default" do
    expect(Terrestrial::Config[:api_url]).to_not be_nil
  end

  context "#load!" do
    it "reads a global config for configuration" do
      allow(Terrestrial::YamlHelper).to receive(:read).with(any_args).and_return(Hash.new)
      allow(Terrestrial::YamlHelper).to receive(:read)
                      .with(Dir.home + "/.terrestrial")
                      .and_return({ global: "config" })

      Terrestrial::Config.load!
      expect(Terrestrial::Config[:global]).to eq "config"
    end

    it "reads the config of the project configuration" do
      allow(Terrestrial::YamlHelper).to receive(:read).with(any_args).and_return(Hash.new)
      allow(Dir).to receive(:pwd)
                      .and_return("/path/to/project")

      allow(Terrestrial::YamlHelper).to receive(:read)
                      .with("/path/to/project/terrestrial.yml")
                      .and_return({ project: "config" })

      Terrestrial::Config.load!
      expect(Terrestrial::Config[:project]).to eq "config"
    end

    it "exits with an error if there is no project configuration folder in the current directory" do
      allow(Dir).to receive(:pwd)
                      .and_return("/path/to/non/existent/project")

      output = capture_stderr do
        expect { 
          Terrestrial::Config.load!
        }.to raise_error SystemExit
      end

      expect(output).to eq "No terrerstrial.yaml found. Are you in the correct folder?\n"
    end
  end

  context "#update_project_config" do
    it "writes the relevant project config to the current terrestrial.yml" do
      allow(Dir).to receive(:pwd).and_return("/path/to/project")

      Terrestrial::Config.load({
        app_id: 123,
        project_id: 456,
        platform: "ios",
        random_value: "asd"
      })

      expect(Terrestrial::YamlHelper).to receive(:update)
        .with("/path/to/project/terrestrial.yml", { app_id: 123, project_id: 456, platform: "ios" })

      Terrestrial::Config.update_project_config
    end
  end

  context "#update_project_config" do
    it "writes the relevant project config to the current terrestrial.yml" do
      allow(Dir).to receive(:home).and_return("/path/to/home")

      Terrestrial::Config.load({
        api_key: "fake_api_key",
        user_id: 789,
        random_value: "asd"
      })

      expect(Terrestrial::YamlHelper).to receive(:update)
        .with("/path/to/home/.terrestrial", { api_key: "fake_api_key", user_id: 789 })

      Terrestrial::Config.update_global_config
    end
  end
end
