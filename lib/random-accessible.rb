require 'random-readable'
require 'random-writable'

module RandomAccessible

  include RandomReadable
  include RandomWritable

  # TODO: Override RandomWritable.#[]= for optimization.

  def collect!(&block)
    
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
