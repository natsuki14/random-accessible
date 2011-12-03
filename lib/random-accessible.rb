# Author:: Natsuki Kawai (natsuki.kawai@gmail.com)
# Copyright:: Copyright 2011 Natsuki Kawai
# License:: 2-clause BSDL or Ruby's


require 'random-readable'
require 'random-writable'

# RandomAccessible mixin provides all instance methods of Array.
# Some methods are defined in RandomReadable or RandomWritable.
# The class must provide one or more methods from read-accessor group ([], at, read_access).
# The class must provide one or more methods from replace-accessor
# ([]=, replace_at, replace_access) and shrink-accessor (shrink) respectively.
# The class may provide insert-accessor (insert_access, insert_at, insert)
# and delete-accessor (delete_access, delete_at).
# The class may provide one size-provider (size, length).
# See the docment of RandomReadable and RandomWritable.
module RandomAccessible

  include RandomReadable
  include RandomWritable

  # TODO: Override RandomWritable.#[]= for optimization.

  # Define modifiers.
  def self.define_modifying_method(*methods)
    methods.each do |method|
      modifier = method.to_s + '!'
      define_method modifier do |*args, &block|
        res = send(method, *args, &block)
        if self == res
          return nil
        else
          replace(res)
          return self
        end
      end
    end
  end
  private_class_method :define_modifying_method

  # TODO: Optimize these methods if it is possible.
  define_modifying_method :compact, :flatten, :uniq

  # Fixed-number-argument version of insert(pos, *val).
  # This method works without override of insert_access.
  def insert_at(pos, val)
    expand 1
    (pos...(size - 1)).reverse_each do |i|
      self[i + 1] = self[i]
    end
    self[pos] = val
  end

  # Same as Array's.
  # See the docment of RandomReadable#collect.
  def collect!(&block)
    if block.nil?
      Enumerator.new do |y|
        size.times do |i|
          self[i] = y.yield(at(i))
        end
      end
    else
      replace(collect(&block))
    end
  end

  # Same as Array's.
  # See the docment of RandomReadable#collect.
  alias :map! :collect!


  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def delete(val, &block)
    deleted = 0
    if method(:delete_at).owner == RandomAccessible
      size.times do |i|
        if at(i) == val
          deleted += 1
        else
          replace_at(i - deleted, at(i))
        end
      end
      shrink deleted
    else
      size.times do |i|
        if at(i) == val
          delete_at(i - deleted)
          deleted += 1
        end
      end
    end

    if deleted > 0
      return val
    elsif block.nil?
      return nil
    else
      return block.call
    end
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider and pos is negative.
  # This method works without delete_access.
  def delete_at(pos)
    if pos < 0
      pos += size
    end
    if pos < 0 || (has_size? && size <= pos)
      return nil
    end

    res = self[pos]
    ((pos + 1)...size).each do |i|
      replace_at(i - 1, at(i))
    end
    shrink 1
    return res
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def delete_if(&block)
    if block.nil?
      reject!
    else
      reject!(&block)
      return self
    end
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def reject!(&block)
    if block.nil?
      return Enumerator.new do |y|
        deleted = 0
        size.times do |i|
          val = self[i - deleted]
          if y.yield(val)
            delete_at(i - deleted)
            deleted += 1
          end
        end
      end
    else
      deleted = 0
      size.times do |i|
        val = self[i]
        if block.call(val)
          deleted += 1
        else
          self[i - deleted] = val
        end
      end
      if deleted > 0
        shrink deleted
        return self
      else
        return nil
      end
    end
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def keep_if(&block)
    if block.nil?
      e = reject!
      return Enumerator.new do |y|
        i = 0
        e.each do
          res = !y.yield(self[i])
          i += 1 unless res
          res
        end
      end
    else
      reject! do |el|
        !block.call(el)
      end
    end
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def pop(*args)
    # Needs size.
    if args.size > 1
      raise ArgumentError, "wrong number of arguments (#{args.size} for 0..1)"
    end

    res = nil
    if args.size == 0
      unless empty?
        res = at(size - 1)
        super
      end
    else
      n = args[0]
      n = size if n > size
      res = self[(size - n)...size]
      super n
    end
    return res
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def reverse!
    # TODO: Optimize me.
    replace(reverse)
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def rotate!(cnt = 1)
    # TODO: Optimize me.
    replace(rotate(cnt))
  end

  alias :select! :keep_if

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def shift(*args)
    if args.size > 1
      raise ArgumentError, "wrong number of arguments (#{args.size} for 0..1)"
    end

    if args.empty?
      res = self[0]
      super
      return res
    else
      n = args[0]
      res = self[0...n]
      super n
      return res
    end
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def shuffle!
    # TODO: Optimize me.
    replace(shuffle)
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides neither size-provider nor delete-accessor.
  def slice!(*args)
    unless (1..2).include?(args.size)
      raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)"
    end

    if args.size == 2 || args[0].is_a?(Range)
      start = len = nil
      if args.size == 2
        start = args[0]
        len = args[1]
      else
        range = args[0]
        start = range.first
        len = range.last - start
        len += 1 unless range.exclude_end?
      end
      res = self[*args]
      len.times do
        delete_at(start)
      end
      return res
    else
      pos = args[0].to_int
      if pos < 0
        pos += size
      end
      if pos < 0 || size <= pos
        return nil
      else 
        res = self[pos]
        delete_at(pos)
        return res
      end
    end
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def sort!(&block)
    # TODO: Optimize me.
    replace(sort(&block))
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides no size-provider.
  def sort_by!(&block)
    # TODO: Optimize me.
    if block.nil?
      data = []
      Enumerator.new do |y|
        each do |el|
          data << y.yield(el)
        end
        i = -1
        sort_by! do
          i += 1
          data[i]
        end
      end
    else
      replace(sort_by(&block))
    end
  end

  # Same as Array's.
  # This method raises NotImplementedError
  # if the class provides neither size-provider nor insert-accessor.
  def unshift(*obj)
    # TODO: Optimize me.
    insert(0, *obj)
  end

end
