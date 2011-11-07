require 'random-readable'
require 'random-writable'

module RandomAccessible

  include RandomReadable
  include RandomWritable

  # TODO: Override RandomWritable.#[]= for optimization.

  def collect!(&block)
    replace(collect(&block))
  end

  alias :map! :collect!

  def compact!
    replace(compact(&block))
  end

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
    ((pos + 1)...size).each do |i|
      replace_at(i - 1, at(i))
    end
    trim 1
  end

  def delete_if(&block)
    if block.nil?
      Enumerator.new |y|
        
    end
  end

  def keep_if(&block)
    #
  end

  def pop(n = nil)
    # Needs size.
    res = nil
    if n.nil?
      res = at(size - 1)
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

  def shuffle!
    # TODO: Optimize me.
    replace(shuffle)
  end

  def slice!(*args)
    result = self[*args]
    self[*args] = nil
    result
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
