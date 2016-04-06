require 'spec_helper'

describe Terrestrial::Cli::VersionChecker do

  it 'compares says if one version is higher than the other' do
    expect(Terrestrial::Cli::VersionChecker.higher_version?('0.0.2', '0.0.1')).to eq true
    expect(Terrestrial::Cli::VersionChecker.higher_version?('0.0.1', '0.0.2')).to eq false

    expect(Terrestrial::Cli::VersionChecker.higher_version?('0.2.2', '0.1.1')).to eq true
    expect(Terrestrial::Cli::VersionChecker.higher_version?('0.1.1', '0.2.2')).to eq false

    expect(Terrestrial::Cli::VersionChecker.higher_version?('3.2.2', '2.1.1')).to eq true
    expect(Terrestrial::Cli::VersionChecker.higher_version?('2.1.1', '3.2.2')).to eq false

    expect(Terrestrial::Cli::VersionChecker.higher_version?('3.0.0', '1.1.1')).to eq true
    expect(Terrestrial::Cli::VersionChecker.higher_version?('0.0.0', '1.1.1')).to eq false
  end

  it 'does not compare beta markers' do
    expect(Terrestrial::Cli::VersionChecker.higher_version?('0.0.2.beta1', '0.0.2')).to eq false
  end
end
