# Author:: Natsuki Kawai (natsuki.kawai@gmail.com)
# Copyright:: Copyright 2011 Natsuki Kawai
# License:: 2-clause BSDL or Ruby's


require 'common-traits'

# RandomReadable mixin allows integer-indexed random access
# and provides non-destructive instance methods. Their name is same as Array.
# The class must provide either read_access, at, or [] method.
# The class may provide size or length method.
# The function of at and [] must be same as Array's.
# read_access(pos) is similar to "at" method, but the module guarantees the argument is positive.
# And if the class provides size or length methods, the argument is less than size or length.
# If the class provides neither size nor length methods, some of the methods of the module
# raises NotImplementedError. Please see the document of each methods.
module RandomReadable

  include RandomAccessible::CommonTraits
  include Enumerable

  # Returns all elements of the class as an Array.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def to_ary
    Enumerator.new do |y|
      size.times do |i|
        y << at(i)
      end
    end.to_a
  end

  alias :to_a :to_ary

  def delegate_to_array(name, *args, &block)
    to_ary.send(name, *args, &block)
  end
  private :delegate_to_array

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def &(other)
    delegate_to_array(:&, other)
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def *(arg)
    delegate_to_array(:*, arg)
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def +(other)
    delegate_to_array(:+, other)
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def -(other)
    delegate_to_array(:-, other)
  end

  # Same as Array's.
  # This method evaluates elements needed to get results.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def <=>(other)
    min_size = [size, other.size].min
    min_size.times do |i|
      res = self[i] <=> other[i]
      return res if res != 0
    end
    return size <=> other.size
  end

  # Same as Array's if the class provides size method.
  # Same as Object's if not.
  # This method evaluates elements needed to get results.
  def ==(other)
    return super unless has_size?
    return false if size != other.size
    size.times do |i|
      return false if self[i] != other[i]
    end

    return true
  end

  # This method is a read-accessor (see README).
  # If you overrides this method, provide same function as Array's.
  # Same as Array's.
  # If the argument is one Integer, this method evaluates one element.
  # If the argument is a Range or start/length, this method evaluates
  # elements in the Range or start/length.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method, and the argument is minus.
  def [](*args)
    if args.size >= 3 || args.size == 0
      raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)"
    end

    if args.size == 2
      start = args[0].to_int
      len   = args[1].to_int
      if has_size?
        return nil if start < -size || size < start
        return nil if len < 0
        return Enumerator.new do |y|
          len.times do |i|
            y << at(start + i) if start + i < size
          end
        end.to_a
      else
        return Enumerator.new do |y|
          len.times do |i|
            y << at(start + i)
          end
        end.to_a
      end
    elsif args[0].is_a? Range
      range = args[0]
      first = range.first
      last = range.last

      if has_size?
        first += size if first < 0
        last += size if last < 0
        last -= 1 if range.exclude_end?
        if first == size || (first == 0 && last < 0)
          return []
        elsif first < 0 || size < first
          return nil
        end
        return Enumerator.new do |y|
          (first..last).each do |i|
            y << at(i) if 0 <= i && i < size
          end
        end.to_a
      else
        range.map do |i|
          at(i)
        end
      end
    else
      at(args[0])
    end
  end

  # Same as Array's.
  # This method sequentially evaluates the elements.
  # Note that this method loops infinitely
  # if the class provides neither size nor lenght method.
  def assoc(key)
    enum = has_size? ? :each : :cycle
    send(enum) do |el|
      if el.respond_to?(:[]) && !el.empty? && el[0] == key
        return el
      end
    end
    return nil
  end

  # This method is a read-accessor (see README).
  # If you overrides this method, provide same function as Array's.
  # Same as Array's.
  # This method evaluates one element.
  # even if the argument is minus or out-of-range.
  def at(pos)
    pos = pos.to_int

    if 0 <= pos && !has_size?
      return read_access(pos)
    elsif 0 <= pos && pos < size
      return read_access(pos)
    elsif -size <= pos && pos < 0
      return read_access(size + pos)
    else
      return nil
    end
  end

  # Need not to override Object#clone and Object#dup

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def combination(n, &block)
    delegate_to_array(:combination, n, &block)
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def compact
    Enumerator.new do |y|
      each do |el|
        y << el unless el.nil?
      end
    end.to_a
  end

  # Same as Array's.
  # This method sequentially evaluates the elements of the class.
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

  # Same as Array's.
  # This method sequentially evaluates the elements of the class.
  # This method or the Enumerator raises NotImplementedError
  # if the class provides neither size nor length method.
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

  # if the object provides size or length, this method is same as Array's
  # and evaluates minimum elements needed to get results.
  # If not, this method is same as Object's and evaluates no element.
  def eql?(other)
    return false unless self.class.eql?(other.class)
    return super(other) unless has_size?

    each_index do |i|
      return false unless at(i).eql?(other.at(i))
    end
    return true
  end

  # Same as Array's.
  # If the argument is an index, this method evaluates one element.
  # If the argument is start/length, this method evaluates
  # elements between the start/length.
  # This method does not accept a minus index
  # if the class provides neither size nor length method.
  def fetch(nth, *args, &block)
    if args.size >= 2
      raise ArgumentError, "wrong number of arguments (#{args.size + 1} for 1..2)"
    end

    if has_size? && (nth < -size || size <= nth)
      if block != nil
        # TODO: Warn if ifnone value is present.
        return block.call
      elsif args.size == 1
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

  # Same as Array's.
  # If the argument is an index, this method evaluates one element.
  # If the argument is start/length, this method evaluates
  # elements between the start/length.
  def first(*args)
    if args.size >= 2
      raise ArgumentError, "wrong number of arguments (#{args.size + 1} for 1..2)"
    end

    if args.size == 1
      width = args[0]
      width = [width, size].min if has_size?

      return self[0...width]
    else
      return at(0)
    end
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def flatten(lv = nil)
    delegate_to_array(:flatten, lv)
  end

  # Same as Array's and evaluates all elements of the class
  # if the class provides size or length method.
  # Same as Object's if not.
  def hash
    return super unless has_size?

    res = 0
    each do |el|
      res += el.hash
    end
    return res
  end

  def include?(val = nil, &block)
    !!index(val, &block)
  end

  # Same as Array's.
  # This method evaluates the elements sequentially.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
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

  # Same as Array's and evaluates all elements of the class
  # if the class provides size or length method.
  # Same as Object's if not.
  def to_s
    return super unless has_size?

    to_ary.to_s
  end

  # Same as Array's and evaluates all elements of the class
  # if the class provides size or length method.
  # Same as Object's if not.
  def inspect
    return super unless has_size?

    to_ary.inspect
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def join(sep = $,)
    to_ary.join(sep)
  end

  # Same as Array's.
  # This method evaluates minimum elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def last(n = nil)
    if n.nil?
      at(size - 1)
    else
      n = size if n > size
      Enumerator.new do |y|
        n.times do |i|
          y << at(size - n + i)
        end
      end.to_a
    end
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # (TODO: Stop evaluating unnecessary elelments)
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def pack(template)
    delegate_to_array(:pack, template)
  end
  
  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def permutation(n, &block)
    delegate_to_array(:permutation, n, &block)
  end
  
  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def product(*lists, &block)
    delegate_to_array(:product, *lists, &block)
  end

  # Same as Array's.
  # This method evaluates minimum elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def rassoc(obj)
    each do |el|
      if el.respond_to?(:[]) && el.size >= 2 && el[1] == obj
        return el
      end
    end
    return nil
  end
  
  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def repeated_combination(n, &block)
    delegate_to_array(:repeated_combination, n, &block)
  end
  
  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def repeated_permutation(n, &block)
    delegate_to_array(:repeated_permutation, n, &block)
  end
  
  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def reverse
    delegate_to_array(:reverse)
  end
  
  # Same as Array's.
  # This method evaluates elements of the class sequentially.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
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

  # Same as Array's.
  # This method evaluates minimum elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def rindex(val = nil, &block)
    i = 0
    if block.nil?
      reverse_each do |el|
        i += 1
        return size - i if el == val
      end
    else
      reverse_each do |el|
        i += 1
        return size - i if block.call(el)
      end
    end
    return nil
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def rotate(cnt = 1)
    delegate_to_array(:rotate, cnt)
  end
  
  # Same as Array's.
  # This method evaluates one elements of the class if there is no argument.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def sample(*args)
    # Needs size.
    if args.size >= 2
      raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)"
    end

    if args.size == 1
      n = [args[0].to_int, size].min
      return Enumerator.new do |y|
        each_index do |i|
          if n > 0 && rand(size - i) < n
            y << at(i)
            n -= 1
          end
        end
      end.to_a.shuffle
    else
      if size == 0
        return nil
      else
        return at(rand(size))
      end
    end
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def shuffle
    delegate_to_array(:shuffle)
  end

  alias :slice :[]

  # sort is defined in Enumerable.

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def transpose
    delegate_to_array(:transpose)
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def uniq(&block)
    delegate_to_array(:uniq, &block)
  end

  # Same as Array's.
  # This method evaluates minimum elements of the class.
  # The arguments must not be negative values
  # if the class does not provide size or length method.
  def values_at(*selectors)
    Enumerator.new do |y|
      selectors.each do |s|
        if s.is_a? Range
          subary = self[s]
          unless subary.nil?
            self[s].each do |el|
              y << el
            end
          end
          if has_size? && !s.exclude_end? && s.include?(size)
            y << nil
          end
        else
          y << self[s.to_int]
        end
      end
    end.to_a
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def zip(*lists, &block)
    delegate_to_array(:zip, *lists, &block)
  end

  # Same as Array's.
  # This method evaluates all elements of the class.
  # This method raises NotImplementedError
  # if the class provides neither size nor length method.
  def |(other)
    delegate_to_array(:|, other)
  end

end
