require 'common-traits'

module RandomWritable

  include RandomAccessible::CommonTraits

  def insert_access(pos, val)
    raise NotImplementedError
  end

  def delete_access(pos)
    raise NotImplementedError
  end

  def replace_at(pos, val)
    if pos < 0
      pos = size + pos
    end
    if has_size? && size <= pos
      expand(pos - size + 1)
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
    if pos < 0
      raise IndexError, "index is too small"
    end
    insert_access(pos, val)
    return self
  end

  def delete_at(pos)
    if pos < 0
      pos = size + pos
    end
    if pos < 0 || (has_size? && size <= pos)
      return nil
    end
    return delete_access(pos)
  end

  def <<(obj)
    index = size
    expand(1)
    replace_access(index, obj)
    return self
  end

  def []=(*args)
    if args.size <= 1 || 4 <= args.size
      raise ArgumentError, "wrong number of arguments (#{args.size} for 2..3)"
    end

    val = args.pop
    if args.size == 2
      start = args[0].to_int
      len = args[1].to_int
      if has_size?
        if start < -size
          raise IndexError, "index #{start} too small for array; minimun: #{-size}"
        end
      else
        if start < 0
          raise IndexError, "index #{start} too small for array; minimun: 0"
        end
      end
      if val.respond_to? :to_ary
        val = val.to_ary
      else
        val = [val]
      end
      if has_size?
        if start + len > size
          len = size - start + 1
        end
        if len <= 0
          len = 1
        end
      end
      if val.size < len
        (len - val.size).times do
          delete_at(start + val.size)
        end
        val.size.times do |i|
          replace_at(start + i, val[i])
        end
      elsif val.size >= len
        len.times do |i|
          replace_at(start + i, val[i])
        end
        (val.size - len).times do |i|
          insert_at(start + len + i, val[len + i])
        end
      end
    elsif args[0].is_a? Range
      range = args[0]
      if !has_size?
        if range.first < 0
          raise RangeError, "#{range.to_s} out of range"
        end
      elsif range.first < -size
        raise RangeError, "#{range.to_s} out of range"
      end
      first = range.first
      last = range.last
      last += 1 unless range.exclude_end?
      self[first, last - first] = val
    else
      replace_at(args[0].to_int, val)
    end
  end

  def clear
    trim(size)
  end

  def concat(other)
    i = size
    expand(other.size)
    other.each do |el|
      replace_at(i, el)
      i += 1
    end
  end

  def fill(*args, &block)
    if args.size > (block.nil? ? 3 : 2) ||
       args.size < (block.nil? ? 1 : 0)
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
      len = args.size == 2 ? args[1] : size
      if block.nil?
        args[1].times do |i|
          replace_at(start + i, val)
        end
      else
        args[1].times do |i|
          index = start + i
          replace_at(index, block.call(index))
        end
      end
    else
      size.times do |i|
        if block.nil?
          replace_at(i, val)
        else
          replace_at(i, block.call(i))
        end
      end
    end
  end

  def insert(nth, *val)
    val.each_with_index do |el, i|
      if nth > 0
        insert_at(nth + i, el)
      else
        insert_at(nth, el)
      end
    end
  end

  def pop(*args)
    if args.size > 1
      raise ArgumentError, "wrong number of arguments (#{args.size})"
    end

    n = 1
    if args.size == 1
      n = args[0].to_int
    end
    trim(n)
    return nil
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
    if args.size > 1
      raise ArgumentError, "wrong number of arguments(#{args.size})"
    end

    n = 1
    unless args.empty?
      n = args[0].to_int
    end
    n.times do
      delete_at(0)
    end
    return nil
  end

end
