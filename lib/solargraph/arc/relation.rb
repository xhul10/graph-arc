module Solargraph
  module Arc
    class Relation
      def self.instance
        @instance ||= self.new
      end

      def process(source_map, ns)
        return [] unless source_map.filename.include?("app/models")

        walker = Walker.from_source(source_map.source)
        pins   = []

        walker.on :send, [nil, :belongs_to] do |ast|
          pins << singular_association(ns, ast)
        end

        walker.on :send, [nil, :has_one] do |ast|
          pins << singular_association(ns, ast)
        end

        walker.on :send, [nil, :has_many] do |ast|
          pins << plural_association(ns, ast)
        end

        walker.on :send, [nil, :has_and_belongs_to_many] do |ast|
          pins << plural_association(ns, ast)
        end

        walker.walk
        Solargraph.logger.debug("[ARC][Relation] added #{pins.map(&:name)} to #{ns.path}") if pins.any?
        pins
      end

      # TODO: handle custom class for relation
      def plural_association(ns, ast)
        relation_name = ast.children[2].children.first

        Util.build_public_method(
          ns,
          relation_name.to_s,
          types: ["ActiveRecord::Associations::CollectionProxy<#{relation_name.to_s.singularize.camelize}>"],
          location: Util.build_location(ast, ns.filename)
        )
      end

      # TODO: handle custom class for relation
      def singular_association(ns, ast)
        relation_name = ast.children[2].children.first

        Util.build_public_method(
          ns,
          relation_name.to_s,
          types: [relation_name.to_s.camelize],
          location: Util.build_location(ast, ns.filename)
        )
      end
    end
  end
end
