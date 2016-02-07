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
        select_translation_files
        create_app_in_web

        if @response.success?
          update_config

          puts "-- Success!"
          puts "App platform added to project! You can view your app at https://mission.terrestrial.io/projects/#{Config[:project_id]}/apps/#{Config[:app_id]}"
          puts ""
          puts "-- What to do next?"
          puts "If you have not internationalized your app, run 'terrestrial flight' to get started."
          puts "If you have already extracted strings out of your app to resource files, make sure you add them to terrestrial.yml,"
          puts "so that Terrestrial can keep track of them."
          puts ""
          puts "Next, run 'terrestrial scan' to see which strings Terrestrial is currently tracking."
          puts "When you're ready to push up your strings, run 'terrestrial push'!"
          puts ""
          puts "For more information, see http://docs.terrestrial.io or jump on Slack at https://terrestrial-slack.herokuapp.com/ if you have any questions."
        else
          puts "Oh snap. There was an error initializing your project."
          puts response.body.inspect
        end
      end

      private
      
      def select_translation_files
        @tranlation_files = [] 

        files = Dir[Config[:directory] + "/**/*.strings"].map {|f| relative_path(f) }
        if files.any?
          @tranlation_files = FilePicker.run(files)
          puts "Tracking #{@tranlation_files.count} files!"
        end
      end

      def update_config
        Terrestrial::Config.load({
          app_id: @response.body["data"]["id"],
          project_id: @project_id,
          platform: @platform,
          api_key: @api_key,
          translation_files: @tranlation_files
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
