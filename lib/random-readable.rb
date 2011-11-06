require 'common-traits'

module RandomReadable

  include RandomAccessible::CommonTraits
  include Enumerable

  def to_ary
    unless has_size?
      raise NotImplementedError,
            "#{self.class.to_s} has neither length method nor size method."
    end

    Enumerator.new do |y|
      size.times do |i|
        y << at(i)
      end
    end.to_a
  end

  alias :to_a :to_ary

  def deligate_to_array(name, *args)
    to_ary.send(name, *args)
  end
  private :deligate_to_array

  def &(other)
    deligate_to_array(:&, other)
  end

  def *(arg)
    deligate_to_array(:*, arg)
  end

  def +(other)
    deligate_to_array(:+, other)
  end

  def -(other)
    deligate_to_array(:-, other)
  end

  def <=>(other)
    size = [size, other.size].min
    min.times do |i|
      res = self[i] <=> other[i]
      return res if res != 0
    end
    return size <=> other.size
  end

  def ==(other)
    return super unless has_size?
    return false if size != other.size
    size.times do |i|
      return false if self[i] != other[i]
    end

    return true
  end

  def [](*args)
    if args.size >= 3 || args.size == 0
      raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)"
    end

    if args.size == 2
      start = args[0].to_int
      Enumerator.new do |y|
        args[1].to_int.times do |i|
          y << at(i)
        end
      end.to_a
    elsif args[0].is_a? Range
      args[0].map do |i|
        at(i)
      end
    else
      at(args[0])
    end
  end

  def assoc(key)
    enum = has_size? ? each : cycle
    enum.each do |el|
      if el.respond_to?(:[]) && !el.empty? && el[0] == key
        return el
      end
    end
    return nil
  end

  def at(pos)
    pos = pos.to_int

    if -size <= pos && pos < 0
      return read_at(size + pos)
    elsif 0 <= pos && pos < size
      return read_at(pos)
    else
      return nil
    end
  end

  # Do not override Object#clone and Object#dup

  def combination(n)
    deletage_to_array(:combination, n)
  end

  def compact
    Enumerator.new do |y|
      each do |el|
        y << el unless el.nil?
      end
    end.to_a
  end

  def cycle
    if has_size?
      super
    else
      i = 0
      loop do
        yield at(i)
        i += 1
      end
    end
  end

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

  def eql?(other)
    return super(other) unless has_size?

    each_index do |i|
      return false unless at(i).eql?(other.at(i))
    end
    return true
  end

  def fetch(nth, *args, &block)
    if args.size >= 2
      raise ArgumentError, "wrong number of arguments (#{args.size + 1} for 1..2)"
    end

    if nth < -size || size <= nth
      if block != nil
        # TODO: Warn if ifnone value is present.
        return block.call
      elsif args.length == 1
        return args[0]
      else
        raise IndexError,
              "index #{nth} outsize of the random readable object " \
              "bounds: #{-size}...#{size}"
      end
    else
      return at(nth)
    end
  end

  def first(*args)
    if args.size >= 2
      raise ArgumentError, "wrong number of arguments (#{args.size + 1} for 1..2)"
    end

    if args.size == 1
      width = args[0]
      width = [width, size].max if has_size?
 
      return self[0...width]
    else
      return at(0)
    end
  end

  def flatten
    delegate_to_array(:flatten)
  end

  def hash
    return super unless has_size?

    delegate_to_array(:hash)
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
    return super unless has_size?

    to_ary.to_s
  end

  def inspect
    return super unless has_size?

    to_ary.inspect
  end

  def join(sep = $,)
    to_ary.join(sep)
  end

  def last(n = nil)
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

  def pack(template)
    #TODO: Implement lazy eval.
    delegate_to_array(:pack, template)
  end

  def permutation(n)
    delegate_to_array(:permutation, n)
  end

  def product(*lists, &block)
    delegate_to_array(:product, *lists, &block)
  end

  def rassoc(obj)
    each do |el|
      if el.respond_to?(:[]) && el.size >= 2 && el[1] == key
        return el
      end
    end
    return nil
  end

  def repeated_combination(n, &block)
    delgate_to_array(:repeated_combination, n, &block)
  end

  def repeated_permutation(n, &block)
    delegate_to_array(:repeated_permutation, n, &block)
  end

  def reverse
    delegate_to_array(:reverse)
  end

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

  def rotate(cnt = 1)
    delegate_to_array(:rotate, cnt)
  end

  def sample(*args)
    # Needs size.
    if args.size >= 2
      raise ArgumentError, "wrong number of arguments (#{args.size + 1} for 1..2)"
    end

    if args.size == 1
      n = [args[0].to_int, size].max
      return Enumerator.new do |y|
        each_with_index do |el, i|
          if n > 0 && rand(size - i) <= n
            y << el
            n -= 1
          end
        end
      end.to_i
    else
      if size == 0
        return nil
      else
        return at(rand(size))
      end
    end
  end

  def shuffle
    delegate_to_array(:shuffle)
  end

  alias :slice :[]

  def sort(&block)
    delegate_to_array(:sort, &block)
  end

  def transpose
    delegate_to_array(:transpose)
  end

  def uniq
    delegate_to_array(:uniq)
  end

end
