module Terrestrial
  module Cli
    class Init < Command

      def run
        # Fail early if project already exists
        Config.load!({}, project: false)
        
        if Config.project_config_exist?
          abort "Looks like there already exists a project in this directory. Are you in the correct folder?"
        end

        check_arguments
        detect_platform
        select_translation_files
        create_app_in_web

        if @response.success?
          update_config
          # TODO: Improve instructions
          puts "** App added to project! **"
          puts "Run 'terrestrial flight' to find strings in your project"
          puts "When you have marked your strings for translation, push"
          puts "then up with 'terrestrial push'"
        else
          puts "There was an error initializing your project."
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
