module SolarRails
  class RailsApi
    def self.instance
      @instance ||= self.new
    end

    def process yard_map
      ann    = File.read(File.dirname(__FILE__) + "/annotations.rb")
      source = Solargraph::Source.load_string(ann, "annotations.rb")
      map    = Solargraph::SourceMap.map(source)

      Solargraph.logger.debug("[Rails] found #{map.pins.size} pins in annotations")

      # TODO: move to annotations.rb when https://github.com/castwide/solargraph/issues/514 is fixed
      overrides = [
        Util.method_return("ActionController::Metal#params", "ActionController::Parameters"),
        Util.method_return("ActionController::Cookies#cookies", "ActionDispatch::Cookies::CookieJar"),
        Util.method_return("ActionDispatch::Flash::FlashHash#now", "ActionDispatch::Flash::FlashNow")
      ]

      ns = Solargraph::Pin::Namespace.new(
        name:  "ActionController::Base",
        gates: ["ActionController::Base"]
      )

      definitions = [
        Util.build_public_method(
          ns,
          "response",
          types: ["ActionDispatch::Response"],
          location: Util.dummy_location("whatever.rb")
        ),
        Util.build_public_method(
          ns,
          "request",
          types: ["ActionDispatch::Request"],
          location: Util.dummy_location("whatever.rb")
        ),
        Util.build_public_method(
          ns,
          "session",
          types: ["ActionDispatch::Request::Session"],
          location: Util.dummy_location("whatever.rb")
        ),
        Util.build_public_method(
          ns,
          "flash",
          types: ["ActionDispatch::Flash::FlashHash"],
          location: Util.dummy_location("whatever.rb")
        )
      ]

      map.pins + definitions + overrides
    end
  end
end