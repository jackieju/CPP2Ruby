STACK = []

class Label
  attr_accessor :name;
  attr_accessor :block;

  def initialize(name, block);
    @name  = name
    @block = block
  end

  def ==(sym)
    @name == sym
  end
end

class Goto < Exception;
  attr_accessor :label
  def initialize(label); @label = label; end
end

def label(sym, &block)
  STACK.last << Label.new(sym, block)
end

def frame_start
  STACK << []
end

def frame_end
  frame = STACK.pop
  idx   = 0

  begin
    for i in (idx...frame.size)
      frame[i].block.call if frame[i].block
    end
  rescue Goto => g
    idx = frame.index(g.label)
    retry
  end
end

def goto(label)
  raise Goto.new(label)
end


# test


def test
    frame_start
    
        label(:a) { print "world!\n"; goto :c } # will be executed directly
        p "1"  # will be executed before any goto
        label(:b) { print "hello "; goto :a }
        p 2  # will be executed before any goto 
        label(:c)
        p 3 # will be executed before any goto
    frame_end # execute the logic in label
    p 4 # executed after all code between frame_start and frame_end
end
test