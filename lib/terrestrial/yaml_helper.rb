require 'yaml'

module Terrestrial
  module YamlHelper
    class << self
      
      def write(path, content)
        File.open(path, 'w') do |f| 
          YAML.dump(content, f) 
        end 
      end

      def read(path)
        YAML.load_file(path)
      end

      def update(path, new_content)
        old_content = read(path)
        write(path, old_content.merge(new_content))
      end
    end
  end
end
