# Terrestrial::Cli

Official Terrestrial command line tool. For more documentation visit the [official docs](http://docs.terrestrial.io/).

If you have any questions, join us on [Slack](https://terrestrial-slack.herokuapp.com/)!

## Installation

    $ gem install terrestrial-cli

## Usage

To get started with your project, cd to your project directory and run

    $ terrestrial init --api-key <API KEY> --project-id <PROJECT ID>

You can find your API key and the correct project ID by logging into [Terrestrial Mission Control](https://mission.terrestrial.io).	

### First time localizing

If you have not internationalized your app before, Terrestrial provides a tool for quickly extracting user-facing strings from your source code:

	$ terrestrial flight
	
##### iOS
	
Flight will scan your source code and, using some clever heuristics, determine which strings can be shown to users. Terrestrial will list all the strings in terminal, and you are able to exclude any strings you wish not to internationalize.

	... 
	Page 5 of 5
	+-------+------------------------------+------------------------------------------------+
	| Index | String                       | File                                           |
	+-------+------------------------------+------------------------------------------------+
	| 40    | Home                         | InspectionMadeEasy/LeftMenuViewController.m:96 |
	+-------+------------------------------+------------------------------------------------+
	| 41    | Home                         | InspectionMadeEasy/MainViewController.m:23     |
	+-------+------------------------------+------------------------------------------------+
	-- Instructions --
	- To exclude any strings from translation, type the index of each string.
	-   e.g. 1,2,4
	------------------
	Any Exclusions? (press return to continue or 'q' to quit at any time)
	
	$ 

After this, Terrestrial generates a **Base.lproj/Localizable.strings** file based on the selected strings, and updates your source code so that each occurence of each strings is properly referenced by ID:

	# Source Code
	label.text = @"This is my string"  =>  label.text = @"THIS_IS_MY_STRING".translated
	
	# The ID is generated based on the original string.
	# The .translated method is simple syntactic sugar over NSLocalizedString, and you
	# are able to fall back to native iOS localization APIs if needed.
	
**Note on Stroyboards:** Terrestrial allows you to easily use strings from your Localizable.strings files inside your Storyboards via IBInspectable properties. During the *flight* process, any strings in Storyboards will have the Terrestrial IBInspectable property turned on, and the string's ID included as a value in the properties. To see this in action, view the Attributed Inspector tab of a UI element in your Storyboards.
	
#### Android

** Documentation coming soon **

### Existing App

If you have already translated your application, Terrestrial needs to know where to find your translation files. This is done via the **terrestrial.yml** file created when your project is initialized:

	---
	app_id: <app ID>
	project_id: <project ID>
	platform: <platform>
	translation_files:
	- /path/to
	- /any/localization/files
	
Terrestrial will keep of the strings listed in the listed files.

### Workflow

As you add strings to you app, either in iOS's Localizable.strings or Android's strings.xml, you can track your changes with:

	$ terrestrial scan
	New Strings: 0
	Removed Strings: 0
	
This will diff your local strings with the current strings stored in Terrestrial. You can see a breakdown of changes by running:

	$ terrestrial scan --verbose
	
When you are ready to upload your local changes with Terrestrial for your translators to get to work, push your latest strings to Terrestrial:

	$ terrestrial push

We suggest running *push* as part of a standard build cycle.

To get the latest translations for your app, run:

	$ terrestrial pull

This will update the necessary language files in your project automatically with updated translations.

### Testing

Terrestrial allows you to start your iOS simulator in a specified locale from the command line:

	$ terrestrial ignite es  # Starts the simulator in Spanish


To upload screenshots, along with metadata of string positions and styles, run the photoshoot command:

	$ terrestrial photoshoot

This will start the simulator and initialize the Terrestrial SDK in photoshoot mode. To upload screenshots to your web dashboard, just tap the injected screenshot button for each screen you wish to upload.


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

