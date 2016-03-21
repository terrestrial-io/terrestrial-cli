module Terrestrial
  module Cli
    class Photoshoot < Command

      WORKING_DIR = '/usr/local/var/terrestrial'

      def run
        Config.load!
        MixpanelClient.track("cli-photoshoot-command")
        scheme = opts[:scheme] 

        if Config[:platform] != "ios"
          abort "Unfortunately photoshoot mode is only supported on iOS at this time."
        end

        if scheme
          puts "Starting simulator in photoshoot mode with scheme \"#{scheme}\"..."
        else
          puts "Starting simulator in photoshoot mode..."
        end
        ensure_var_folder_exists

        workspace = Dir["#{Config[:directory]}/*.xcworkspace"][0]
        project = Dir["#{Config[:directory]}/*.xcodeproj"][0]

        # Kill simulator and 
        system("killall \"Simulator\" &> /dev/null")
        `rm -rf #{WORKING_DIR}`

        if workspace 
          # If a workspace exists we want to build it instead of the project.
          # We assume the scheme we want to use is simply the application name
          app_name = File.basename(workspace).split(".").first
          `xcodebuild -workspace "#{workspace}" -destination 'platform=iOS Simulator,name=iPhone 6s' -scheme #{scheme || app_name} -configuration Debug clean build CONFIGURATION_BUILD_DIR=#{WORKING_DIR}`
        else
          app_name = File.basename(project).split(".").first
          `xcodebuild -project "#{project}" -destination 'platform=iOS Simulator,name=iPhone 6s' -scheme #{scheme || app_name} -configuration Debug clean build CONFIGURATION_BUILD_DIR=#{WORKING_DIR}`
        end
        `open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app`

        # Here we literally sleep until the Simulator has been booted
        wait_until_booted = %{
          count=`xcrun simctl list | grep Booted | wc -l | sed -e 's/ //g'`
          while [ $count -lt 1 ]
          do
              sleep 1
              count=`xcrun simctl list | grep Booted | wc -l | sed -e 's/ //g'`
          done
        }
        `#{wait_until_booted}`

        # Here we magically find the bundle identifier of the app
        command = "defaults read \"#{Dir[WORKING_DIR + '/*.app/Info.plist'].first}\" CFBundleIdentifier"
        bundle_name = `#{command}`.chop

        # Reinstall the app,
        # Run it with the locale we want
        `xcrun simctl uninstall booted #{bundle_name}`
        `xcrun simctl install booted "#{Dir[WORKING_DIR + "/" + (scheme || app_name) + ".app"].first}"`
        `xcrun simctl launch booted #{bundle_name} --args -TerrestrialScreenShotMode YES -TerrestrialAPIToken "#{Config[:api_key]}" -TerrestrialAppId "#{Config[:app_id]}" -TerrestrialProjectId "#{Config[:project_id]}" -TerrestrialURL "#{Config[:api_url]}"`
      end

      def ensure_var_folder_exists
        `mkdir -p #{WORKING_DIR}`
      end
    end
  end
end
