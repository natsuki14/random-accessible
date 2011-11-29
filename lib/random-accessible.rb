require 'random-readable'
require 'random-writable'

module RandomAccessible

  include RandomReadable
  include RandomWritable

  # TODO: Override RandomWritable.#[]= for optimization.

  def self.define_modifying_method(*methods)
    methods.each do |method|
      modifier = method.to_s + '!'
      define_method modifier do |*args|
        res = send(method, *args)
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

  alias :map! :collect!

  # TODO: Optimize these methods if it is possible.
  define_modifying_method :compact, :flatten

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
      trim deleted
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
    trim 1
    return res
  end

  def delete_if(&block)
    if block.nil?
      reject!
    else
      reject!(&block)
      return self
    end
  end

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
        trim deleted
        return self
      else
        return nil
      end
    end
  end

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

  def pop(n = nil)
    # Needs size.
    res = nil
    if n.nil?
      unless empty?
        res = at(size - 1)
        trim 1
      end
    else
      n = size if n > size
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

  alias :select! :keep_if

  def shuffle!
    # TODO: Optimize me.
    replace(shuffle)
  end

  def slice!(*args)
    unless (1..2).include?(args.size)
      raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)"
    end

    if args.size == 2 || args[0].is_a?(Range)
      res = self[*args]
      self[*args] = nil
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

  def sort!(&block)
    # TODO: Optimize me.
    replace(sort(&block))
  end

  def sort_by!(&block)
    # TODO: Optimize me.
    replace(sort_by(&block))
  end

  def uniq!(&block)
    replace(uniq(&block))
  end

  def unshift(*obj)
    # TODO: Optimize me.
    obj.each do |el|
      insert_at(0, el)
    end
  end

end
