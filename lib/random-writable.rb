require 'common-traits'

module RandomWritable

  include RandomAccessible::CommonTraits

  def replace_at(pos, val)
    if pos < 0
      pos = size + pos
    end
    replace_access(pos, val)
    return self
  end

  def expand(n)
    # Nothing to do.
    # Override if you need something to do
    # when expanding the object.
  end

  def insert_at(pos, val)
    if pos < 0
      pos = size + pos + 1
    end
    insert_access(pos, val)
    return self
  end

  def delete_at(pos)
    if pos < 0
      pos = size + pos
    end
    delete_access(pos)
    return nil
  end

  def <<(obj)
    replace_access(size, obj)
  end

  def []=(*args)
    if args.size <= 1 || 4 <= args.size
      ArgumentError, "wrong number of arguments (#{args.size} for 2..3)"
    end

    val = args.pop
    if args.size == 2
      start = args[0].to_int
      len = args[1].to_int
      if start < -size
        raise IndexError, "index #{start} too small for array; minimun: #{-size}"
      end
      if val.respond_to? :to_ary
        val = val.to_ary
      else
        val = [val]
      end
      if val.size < len
        val.size.times do |i|
          replace_at(start + i, val[i])
        end
        (len - val.size).times do
          delete_at(start + val.size)
        end
      elsif val.size >= len
        len.times do |i|
          replace_at(start + i, val[i])
        end
        (val.size - len).times do |i|
          insert_at(start + len + i, val[i])
        end
      end
    elsif args[0].is_a? Range
      range = args[0]
      if range.first < -size
        raise RangeError, "#{range.to_s} out of range"
      end
      self[range.first, range.length]
    else
      replace_at(args[0].to_int, val)
    end
  end

  def clear
    trim(size)
  end

  def concat(other)
    expand(other.size)
    i = size
    other.each do |el|
      replace_at(i, el)
      i += 1
    end
  end

  def fill(*args, &block)
    if args.size >= (block.nil? ? 3 : 2) ||
       args.size <= (block.nil? ? 1 : 0)
      raise ArgumentError, "wrong number of arguments (#{args.size})"
    end

    val = nil
    if block.nil?
      val = args.shift
    end

    if args[0].is_a? Range
      range = args[0]
      if block.nil?
        fill(val, range.first, range.last - range.first)
      end
    elsif args.size != 0
      start = args[0].to_int
      len = args.size == 2 ? args[1], size
      if block.nil?
        args[1].times do |i|
          replace_at(start + i, val)
        end
      else
        args[1].times do |i|
          replace_at(start + i, block.call(i))
        end
      end
    else
      size.times do |i|
        replace_at(i, val)
      end
    end
  end

  def insert(nth, *val)
    val.each_with_index do |el, i|
      insert_at(nth, el)
    end
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

  def shift(*args)
    n = nil
    if args.empty?
      n = 1
      return nil if empty?
    else
      n = args[0].to_int
      return [] if empty?
    end
    res = self[0...n]
    (size - n).times do |i|
      replace_at(i, at(i + n))
    end
    trim n
    return res
  end

end
