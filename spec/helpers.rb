module Helpers
  def load_string(filename, str)
    source = build_source(filename, str)
    map = Solargraph::SourceMap.map(source)
    api_map.catalog Solargraph::Bench.new(source_maps: [map])
    # api_map.map(source)
    source
  end

  def callstack
    caller.reject {|f| f.include?("pry") || f.include?("rspec") }
  end

  class Injector
    attr_reader :files
    def initialize(folder)
      @folder = folder
      @files  = []
    end

    def write_file(path, content)
      File.write(path, content)
      @files << path
    end
  end

  def use_workspace(folder, &block)
    injector = Injector.new(folder)
    map      = nil

    Dir.chdir folder do
      yield injector
      map = Solargraph::ApiMap.load("./")
      injector.files.each {|f| File.delete(f) }
    end

    map
  end

  def build_source(filename, str)
    Solargraph::Source.load_string(str, filename)
  end

  def find_pin(path)
    api_map.pins.find {|p| p.path == path }
  end

  def local_pins
    api_map.pins.select {|p| p.filename }
  end

  def methods_for(pin: nil, path: nil)
    pin ||= find_pin(path)
    api_map.get_complex_type_methods(pin.return_type)
  end

  def local_methods_for(pin: nil, path: nil)
    methods_for(pin: pin, path: path).select {|m| m.filename }
  end

  def completion_at(filename, position, map=api_map)
    clip = map.clip_at(filename, position)
    cursor = clip.send(:cursor)
    word = cursor.chain.links.first.word

    Solargraph.logger.debug("Complete: word=#{word}, links=#{cursor.chain.links}")

    clip.complete.pins.map(&:name)
  end
end
