module Terrestrial
  module Cli
    class SimulatorLauncher

      WORKING_DIR = '/usr/local/var/terrestrial'

      def initialize(args: nil, scheme: nil)
        @scheme = scheme
        @args = args
      end

      def run
        cleanup_simulator
        build_app
        launch_simulator
        wait_until_simulator_booted

        reinstall_app
        launch_app_with_args
      end

      private

      def cleanup_simulator
        ensure_var_folder_exists

        system("killall \"Simulator\" &> /dev/null")
        `rm -rf #{WORKING_DIR}`
      end

      def build_app
        c = "xcodebuild #{is_workspace? ? '-workspace' : '-project' } \"#{project_path}\" " +
            "-destination 'platform=iOS Simulator,name=iPhone 6s' " +
            "-scheme #{scheme} " +
            "-configuration Debug clean build CONFIGURATION_BUILD_DIR=#{WORKING_DIR}"

        `#{c}`
      end

      def launch_simulator
        `open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app`
      end

      def wait_until_simulator_booted
        wait_until_booted = %{
          count=`xcrun simctl list | grep Booted | wc -l | sed -e 's/ //g'`
          while [ $count -lt 1 ]
          do
              sleep 1
              count=`xcrun simctl list | grep Booted | wc -l | sed -e 's/ //g'`
          done
        }
        `#{wait_until_booted}`
      end

      def reinstall_app
        `xcrun simctl uninstall booted #{bundle_identifer}`
        `xcrun simctl install booted "#{Dir[WORKING_DIR + "/" + (bundle_name) + ".app"].first}"`
      end

      def launch_app_with_args
        c = "xcrun simctl launch booted #{bundle_identifer} --args " + LaunchArgsBuilder.build(args)

        `#{c}`
      end

      def project_path
        # Try to find a workspace, fall back to project, finally fail
        @project_path ||= Dir["#{Config[:directory]}/*.xcworkspace"][0] || 
                        Dir["#{Config[:directory]}/*.xcodeproj"][0] || 
                        raise('Could not find workspace or project in folder')
      end

      def scheme
        @scheme || app_name
      end

      def app_name
        @app_name ||= File.basename(project_path).split(".").first
      end

      def args
        @args ||= {}
      end

      def is_workspace?
        project_path.end_with?('xcworkspace')
      end

      def ensure_var_folder_exists
        `mkdir -p #{WORKING_DIR}`
      end

      def bundle_identifer
        # Fetch the bundle identifier from the project's Info.plist folder
        @bundle_identifer ||= `defaults read \"#{Dir[WORKING_DIR + '/*.app/Info.plist'].first}\" CFBundleIdentifier`.chomp
      end

      def bundle_name
        # Fetch the bundle display name from the project's Info.plist folder
        @bundle_name ||= `defaults read \"#{Dir[WORKING_DIR + '/*.app/Info.plist'].first}\" CFBundleName`.chomp
      end
    end
  end
end

module Terrestrial
  module Cli
    class SimulatorLauncher
      class LaunchArgsBuilder

        def self.build(args)
          result = []

          args.each do |key, value|
            result << "-#{key}"
            result << build_value(value)
          end

          result.join(" ")
        end

        def self.build_value(value)
          if value.class == TrueClass
            'YES'
          elsif value.class == FalseClass
            'NO'
          else
            "\"#{value}\""
          end
        end
      end
    end
  end
end
