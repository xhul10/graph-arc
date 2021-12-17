module Solargraph
  module Arc
    class Debug
      def self.run(query=nil)
        self.new.run(query)
      end

      def run(query)
        Solargraph.logger.level = Logger::DEBUG

        api_map = Solargraph::ApiMap.load('./')

        puts "Ruby version: #{RUBY_VERSION}"
        puts "Solargraph version: #{Solargraph::VERSION}"
        puts "Solargraph ARC version: #{Solargraph::Arc::VERSION}"

        return unless query

        puts "Known methods for #{query}"

        pin = api_map.pins.find {|p| p.path == query }
        return unless pin

        api_map.get_complex_type_methods(pin.return_type).each do |pin|
          puts "- #{pin.path}"
        end
      end
    end
  end
end
