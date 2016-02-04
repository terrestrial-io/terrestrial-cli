require 'spec_helper'

describe Terrestrial::Cli::FileFinder do
  it "makes sure to exclude folders that are blacklisted" do
    allow(Dir).to receive(:[]).and_return([
      "#{Dir.pwd}/foo/Carthage/ViewController.m",
      "#{Dir.pwd}/foo/Pods/ViewController.m",
      "#{Dir.pwd}/foo/FooTests/ViewController.m",
      "#{Dir.pwd}/foo/ThisIsOk/ViewController.m"
    ])

    expect(Terrestrial::Cli::FileFinder.find(Dir.pwd, ".m")).to eq ["foo/ThisIsOk/ViewController.m"]
  end

  it "exludes LaunchScreen.storyboard files" do
    allow(Dir).to receive(:[]).and_return([
      "#{Dir.pwd}/foo/bar/Main.storyboard",
      "#{Dir.pwd}/foo/bar/LaunchScreen.storyboard"
    ])

    expect(Terrestrial::Cli::FileFinder.find(Dir.pwd, ".storyboard")).to eq ["foo/bar/Main.storyboard"]
  end

  it "finds strings.xml files that are in the correct folder struture" do
    allow(Dir).to receive(:[]).and_return([
      "#{Dir.pwd}/foo/strings.xml",
      "#{Dir.pwd}/foo/res/values/strings.xml"
    ])

    expect(Terrestrial::Cli::FileFinder.find(Dir.pwd, ".xml")).to eq ["foo/res/values/strings.xml"]
  end
end
