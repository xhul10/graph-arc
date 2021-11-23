require 'solargraph'
require 'pry'

ast = Solargraph::Parser.parse_with_comments(File.read("db/schema.rb"), "db/schema.rb")

class Walker
  class Hook
    attr_reader :args, :proc, :node_type
    def initialize(node_type, args, &block)
      @node_type = node_type
      @args = args
      @proc = Proc.new(&block)
    end
  end

  def initialize(ast)
    @ast   = ast
    @hooks = Hash.new([])
  end

  def on(node_type, args, &block)
    @hooks[node_type] << Hook.new(node_type, args, &block)
  end

  def walk
    if @ast.is_a?(Array)
      @ast.each { |node| traverse(node) }
    else
      traverse(@ast)
    end
  end

private

  def traverse(node)
    return unless node.is_a?(Parser::AST::Node)

    @hooks[node.type].each do |hook|
      try_match(node, hook)
    end

    node.children.each {|child| traverse(child) }
  end

  def try_match(node, hook)
    return unless node.type == hook.node_type
    return unless node.children

    matched = node.children.any? do |child|
      next unless child.is_a?(Parser::AST::Node)
      next unless child.type == hook.args.first
      hook.args[1..-1].each_with_index.all? { |arg, i| child.children[i] == arg }
    end

    hook.proc.call(node) if matched
  end
end

walker = Walker.new(ast)
walker.on :block, [:send, nil, :create_table] do |ast|
  pp ast
  binding.pry
  puts "\n"
end

walker.walk
