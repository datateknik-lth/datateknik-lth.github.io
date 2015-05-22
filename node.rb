class Node
  attr_reader :name, :files

  def initialize(name, parent)
    @children = {}
    @files = []
    @name = name
    @parent = parent
  end

  def children
    @children.values
  end

  def [](key)
    @children[key]
  end

  def add_resource(*args)
    if args.length == 1
      @files << args[0]
      self
    else
      @children.merge!({args[0] => Node.new(args[0], self) }) unless @children.has_key? args[0]
      @children[args[0]].add_resource(*args[1..-1])
    end
  end

  def path
    return "/#{name}" if @parent.nil?
    "#{@parent.path}/#{name}"
  end
end
