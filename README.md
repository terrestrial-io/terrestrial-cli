# Terrestrial::Cli

[![Build Status](https://circleci.com/gh/terrestrial-io/terrestrial-cli.svg?style=shield)](https://circleci.com/gh/terrestrial-io/terrestrial-cli)

Official Terrestrial command line tool. For documentation visit the [official docs](http://docs.terrestrial.io/).

You can also join us on [Slack](https://terrestrial-slack.herokuapp.com/) to chat with the team directly.

## Installation

    $ gem install terrestrial-cli

## Usage

To get started with your project, cd to your project directory and run

    $ terrestrial init --api-key <API KEY> --project-id <PROJECT ID>

You can find your API key and the correct project ID by logging into [Terrestrial Mission Control](https://mission.terrestrial.io).	

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/terrestrial-io/terrestrial-cli.

## Development

To run the gem in development, run

    ruby -Ilib bin/terrestrial <COMMAND>

To build the gem and install it in your current Gemset, run 

    rake build

To run tests

    rspec

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

