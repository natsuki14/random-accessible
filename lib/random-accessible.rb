module RandomAccessable

  module CommonFunctions

    def each_index(&block)
      if block.nil?
        Enumerator.new do |y|
          size.times do |i|
            y << i
          end
        end
      else
        size.times do |i|
          block.call(i)
        end
      end
    end

    def empty?
      size <= 0
    end

    # TODO: Implement size and length

  end

end

module RandomReadable

  def to_ary
    Enumerator.new do |y|
      size.times do |i|
        y << at(i)
      end
    end.to_a
  end

  alias :to_a :to_ary

  def deligate_to_array(name, *args)
    if Array.public_method_defined?(name)
      return to_ary.send(name, *args)
    else
      super(name, *args)
    end
  end
  private :deligate_to_array
  alias :method_missing :deligate_to_array

  #def &(other)
  #end

  #def *(arg)
  #end

  #def +(other)
  #end

  #def -(other)
  #end


  def <=>(other)
    size = [size, other.size].min
    min.times do |i|
      res = self[i] <=> other[i]
      return res if res != 0
    end
    return size <=> other.size
  end

  def ==(other)
    return false if size != other.size
    size.times do |i|
      return false if self[i] != other[i]
    end

    return true
  end

  def assoc(key)
    each do |el|
      if el.respond_to?(:[]) && !el.empty? && el[0] == key
        return el
      end
    end
    return nil
  end


  # Do not override Object#clone and Object#dup

  #def combination(n)
  #end

  def compact
    return @substance.compact if @substance

    Enumerator.new do |y|
      each do |el|
        y << el unless el.nil?
      end
    end.to_a
  end


  # self#cycle is defined in Enumerable.

  def each(&block)
    if block.nil?
      return Enumerator.new do |y|
        size.times do |i|
          y << self[i]
        end
      end
    else
      size.times do |i|
        block.call(self[i])
      end
      return self
    end
  end

  def eql?
    #
  end

  def fetch(nth, *args, &block)
    #
  end

  def first(n = 0)
    #
  end

  #def flatten
  #end

  def hash
    #
  end

  def include?(val = nil, &block)
    !!index(val, &block)
  end

  def index(val = nil, &block)
    # needs size
    if block.nil?
      each_with_index do |el, index|
        return index if el == val
      end
    else
      each_with_index do |el, index|
        return index if block.call(el)
      end
    end
    return nil
  end

  # indexes is not defined on Ruby 1.9.

  def to_s
    # Needs size.
    to_ary.to_s
  end

  def inspect
    # Needs size.
    to_ary.inspect
  end

  def join(sep = $,)
    # Needs size.
    to_ary.join(sep)
  end

  def last(n = nil)
    # Needs size.
    if n.nil?
      at(size - 1)
    else
      Enumerator.new do |y|
        n.times do |i|
          y << at(size - n + i)
        end
      end.to_a
    end
  end

  #def pack(template)
  # TODO: Implement lazy eval.
  #end

  #def permutation(n)
  #end

  #def product(*lists, &block)
  #end

  def rassoc(obj)
    each do |el|
      if el.respond_to?(:[]) && el.size >= 2 && el[1] == key
        return el
      end
    end
    return nil
  end

  #def repeated_combination(n, &block)
  #end

  #def repeated_permutation(n, &block)
  #end

  #def reverse
  #end

  def reverse_each(&block)
    # Needs size.
    if block.nil?
      Enumerator.new do |y|
        (size - 1).downto 0 do |i|
          y << at(i)
        end
      end
    else
      (size - 1).downto 0 do |i|
        yield at(i)
      end
    end
  end

  def rindex(val = nil, &block)
    if block.nil?
      reverse_each do |el|
        return el if el == val
      end
    else
      reverse_each do |el|
        return el if block.call(el)
      end
    end
    return nil
  end

  #def rotate(cnt = 1)
  #end

  def sample(n = nil)
    #
  end

end

module RandomWritable

  def expand(n)
    # Nothing to do.
    # Override if you need something to do
    # when expanding the object.
  end

  def <<(obj)
    replace_at(size) = obj
  end

  #def []=(*args)
  #end

  def clear
    #
  end

  def concat
    #
  end

  def fill
    #
  end

  def insert(nth, *val)
    #
  end

  def push(*obj)
    obj.each do |el|
      replace_at(size, el)
    end
  end

  def replace(another)
    diff = another.size - size
    trim -diff if diff < 0
    expand diff if diff > 0
    another.each_with_index do |el, index|
      replace_at(index, el)
    end
    return self
  end

end

module RandomAccessible

  def collect!(&block)
    #
  end

  alias :map! :collect!

  def compact!
    #
  end

  def delete
    #
  end

  #def delete_at(pos)
  #end

  def delete_if(&block)
    #
  end

  def keep_if(&block)
    #
  end

  def pop(n = nil)
    # Needs size.
    res = nil
    if n.nil?
      res = self.at(size - 1)
      trim 1
    else
      res = self[(size - n)...size]
      trim n
    end
    return res
  end

  def reverse!
    # TODO: Optimize me.
    replace(reverse)
  end

  def rotate!(cnt = 1)
    # TODO: Optimize me.
    replace(rotate(cnt))
  end

  def select!(&block)
    # TODO: Optimize me.
    replace(select(&block))
  end

end
