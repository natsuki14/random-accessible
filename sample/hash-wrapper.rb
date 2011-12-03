require 'random-accessible'


class HashWrapper
    
  include RandomAccessible
  
  # You can define arbitral initializer.
  def initialize(ary = nil)
    @h = Hash.new
    if ary.nil?
      @size = 0
    else
      ary.each_with_index do |el, i|
        @h[i] = el
      end
      @size = ary.size
    end
  end
  
  # Define a read-accessor.
  # The easiest method to implement is read_access.
  def read_access(pos)
    # The mixin guarantees 0 <= pos < size.
    raise if pos < 0 && @size <= pos
    return @h[pos]
  end

  # Define a replace-accessor.
  # We recommend that implement replace_access.
  def replace_access(pos, val)
    raise if pos < 0 && @size <= pos
    @h[pos] = val
  end
  
  # Define expand.
  # This method is called when increasing the object's size.
  def expand(n)
    n.times do
      @h[@size] = nil
      @size += 1
    end
  end
    
  # Define shrink.
  # This method is called when decreasing the object's size.
  def shrink(n)
    n.times do
      @h.delete(@size - 1)
      @size -= 1
    end
  end
  
  # Define a size-provider.
  # You can choose from size and length method.
  attr_reader :size
  
end

