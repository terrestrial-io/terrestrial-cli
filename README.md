# Terrestrial::Cli


## Installation

    $ gem install terrestrial-cli

## Usage

To get started with your project, cd to your project repository and run

    $ terrestrial init --api-key <API KEY> --project-id <PROJECT ID>

You can find your API key and the correct project ID by logging into [Terrestrial Misson Control](https://mission.terrestrial.io).	

### First time localizing

If you have not internationalized your app before, Terrestrial provides a tool for quickly extracting user-facing strings from your source code:

	$ terrestrial flight
	
##### iOS
	
Flight will scan your source code and, using some clever heuristics, determine which strings can be shown to users. Terrestrial will list all the strings in terminal, and you are able to exclude any strings you wish not to internationalize.

	... 
	Page 5 of 6
	+-------+------------------------------+------------------------------------------------+
	| Index | String                       | File                                           |
	+-------+------------------------------+------------------------------------------------+
	| 40    | Home                         | InspectionMadeEasy/LeftMenuViewController.m:96 |
	+-------+------------------------------+------------------------------------------------+
	| 41    | Home                         | InspectionMadeEasy/MainViewController.m:23     |
	+-------+------------------------------+------------------------------------------------+
	| 42    | History                      | InspectionMadeEasy/LeftMenuViewController.m:96 |
	+-------+------------------------------+------------------------------------------------+
	| 43    | Support                      | InspectionMadeEasy/LeftMenuViewController.m:96 |
	+-------+------------------------------+------------------------------------------------+
	| 44    | Log Out                      | InspectionMadeEasy/LeftMenuViewController.m:96 |
	+-------+------------------------------+------------------------------------------------+
	| 45    | Choose Inspection Checklist: | InspectionMadeEasy/MainViewController.m:55     |
	+-------+------------------------------+------------------------------------------------+
	| 46    | Cancel                       | InspectionMadeEasy/MainViewController.m:55     |
	+-------+------------------------------+------------------------------------------------+
	| 47    | Electrical                   | InspectionMadeEasy/MainViewController.m:57     |
	+-------+------------------------------+------------------------------------------------+
	| 48    | Pipeline                     | InspectionMadeEasy/MainViewController.m:58     |
	+-------+------------------------------+------------------------------------------------+
	| 49    | Mechanical                   | InspectionMadeEasy/MainViewController.m:59     |
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

