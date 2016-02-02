require 'yaml'

module Terrestrial
  module YamlHelper
    class << self
      
      def write(path, content)
        File.open(path, 'w+') do |f| 
          f.write stringfy_keys(content).to_yaml
        end 
      end

      def read(path)
        symbolize_keys(YAML.load_file(path))
      end

      def update(path, new_content)
        begin
          old_content = read(path)
        rescue Errno::ENOENT
          old_content = {}
        end

        write(path, old_content.merge(new_content))
      end

      private

      def stringfy_keys(h)
        h.keys.each do |k|
          ks    = k.respond_to?(:to_s) ? k.to_s: k
          h[ks] = h.delete k # Preserve order even when k == ks
          stringfy_keys h[ks] if h[ks].kind_of? Hash
        end
        h
      end

      def symbolize_keys(h)
        h.keys.each do |k|
          ks    = k.respond_to?(:to_sym) ? k.to_sym : k
          h[ks] = h.delete k # Preserve order even when k == ks
          symbolize_keys! h[ks] if h[ks].kind_of? Hash
        end
        h
      end
    end
  end
end
