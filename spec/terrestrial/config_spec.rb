require 'spec_helper'
require 'yaml'

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
      allow(YAML).to receive(:load_file).with(any_args).and_return(Hash.new)
      allow(YAML).to receive(:load_file)
                      .with(Dir.home + "./terrestrial")
                      .and_return({ global: "config" })

      Terrestrial::Config.load!
      expect(Terrestrial::Config[:global]).to eq "config"
    end

    it "reads the config of the project configuration" do
      allow(YAML).to receive(:load_file).with(any_args).and_return(Hash.new)
      allow(Dir).to receive(:pwd)
                      .and_return("/path/to/project")

      allow(YAML).to receive(:load_file)
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
end
