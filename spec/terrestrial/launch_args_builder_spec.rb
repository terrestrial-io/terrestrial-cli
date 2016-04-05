require 'spec_helper'

describe Terrestrial::Cli::SimulatorLauncher::LaunchArgsBuilder do

  LaunchArgsBuilder = Terrestrial::Cli::SimulatorLauncher::LaunchArgsBuilder

  it 'joins arguments together into a string' do
    expect(LaunchArgsBuilder.build({
      'Foo' => 'bar',
      'Fizz' => 'Buz'
    })).to eq '-Foo "bar" -Fizz "Buz"'
  end

  it 'does converts booleans to unescaped YES and NO' do
    expect(LaunchArgsBuilder.build({
      'Foo' => 'bar',
      'Fizz' => true,
      'Chuck' => false,
    })).to eq '-Foo "bar" -Fizz YES -Chuck NO'
  end
end
