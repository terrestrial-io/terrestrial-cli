module Terrestrial
  module Cli
    class Init < Command

      def run
        # Fail early if project already exists
        Config.load!({}, project: false)
        MixpanelClient.track("cli-init-command")
        
        if Config.project_config_exist?
          abort "Looks like there already exists a project in this directory. Are you in the correct folder?"
        end

        check_arguments
        detect_platform

        puts "-- Terrestrial Initializing"
        puts "Adding new app! Searching for localization files..."

        TerminalUI.show_spinner do
          # Otherwise the whole process is too quick for the eye
          sleep 2 unless Config.testing?
        end
        puts ""

        select_translation_files
        create_app_in_web

        if @response.success?
          update_config

          puts "-- Success!"
          puts "App platform added to project! You can view your app at https://mission.terrestrial.io/projects/#{Config[:project_id]}/apps/#{Config[:app_id]}"
          puts ""
          puts "-- What to do next?"

          if @translation_files.any?
            puts "Run 'terrestrial scan' to see which strings Terrestrial is currently tracking."
            puts "When you're ready to upload your strings for translation, run 'terrestrial push'!"
          elsif @translation_files.none? && @platform == "ios"
            puts "To get started localizing your app, run 'terrestrial flight'."
            puts "Terrestrial will scan your code for strings, and generate the necessary localization files."
          elsif @translation_files.none? && @platform == "android"
            puts "Looks like Terrestrial does not know which strings.xml files to track."
            puts "To continue, add your base language strings.xml file to terrestrial.yml."
            puts "When you're ready, run 'terrestrial scan' to see which strings Terrestrial is tracking, and 'terrestrial push' to upload."
          end
          puts ""
          puts "For more information, see http://docs.terrestrial.io or jump on Slack at https://terrestrial-slack.herokuapp.com/ if you have any questions."
        else
          puts "Oh snap. There was an error initializing your project."
          puts response.body.inspect
          abort
        end
      end

      private
      
      def select_translation_files
        @translation_files = [] 

        files = find_platform_translation_files
        if files.any?
          @translation_files = FilePicker.run(files, @platform)
          
          if @translation_files.count == 1
            puts "Tracking #{@translation_files.count} file!"
          else
            puts "Tracking #{@translation_files.count} files!"
          end
        end
      end

      def find_platform_translation_files
        if @platform == "ios"
          Dir[Config[:directory] + "/**/*.strings"].map {|f| relative_path(f) }
        elsif @platform == "android"
          Dir[Config[:directory] + "/**/*/res/values/strings.xml"].map {|f| relative_path(f) }
        else
          raise "Unknown platform #{@platform}"
        end
      end

      def update_config
        Terrestrial::Config.load({
          app_id: @response.body["data"]["id"],
          project_id: @project_id,
          platform: @platform,
          api_key: @api_key,
          translation_files: @translation_files
        })

        Terrestrial::Config.update_global_config
        Terrestrial::Config.update_project_config
      end

      def create_app_in_web
        @client = Terrestrial::Web.new(@api_key)
        @response = @client.create_app(@project_id, @platform)
      end

      def check_arguments
        @api_key = opts[:api_key] || Config[:api_key] || 
                 abort("No api key provided. You can find your API key at https://mission.terrestrial.io/.")

        @project_id = opts.fetch(:project_id) { abort(
          "No project ID provided. Terrestrial needs to know which project this app belongs to.\n" +
          "Visit https://mission.terrestrial.io to find your project ID."
        )}
      end

      def detect_platform
        @platform = DetectsProjectType.run
      end

      def project_id
        @project_id
      end

      def api_key
        @api_key
      end

      def relative_path(file)
        current_dir = Pathname.new(Config[:directory])

        Pathname.new(file)
          .relative_path_from(current_dir)
          .to_s
      end
    end
  end
end
