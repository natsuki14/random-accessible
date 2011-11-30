require 'test/unit'
require 'random-accessible'

class FullImpl

  include RandomAccessible

  def initialize(ary)
    @a = ary
    @size = ary.size
  end

  def read_access(pos)
    if pos < 0 || @size <= pos
      raise ErrorForTest, "size=#{@size} pos=#{pos}"
    end
    @a.at(pos)
  end

  def replace_access(pos, obj)
    if pos < 0 || @size <= pos
      raise ErrorForTest, "size=#{@size} pos=#{pos}"
    end
    @a[pos] = obj
  end

  def expand(n)
    @size += n
  end

  def trim(n)
    @size -= n
    @a.pop(n)
  end

  def size
    @size
  end

end

FULL_IMPLS = [Array, FullImpl]

class TestRandomAccesible < Test::Unit::TestCase

  def test_collect!
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      impl.collect! do |el|
        el * 3
      end
      assert_equal([3, 6, 9], impl)
      assert_equal(3, impl.size)

      impl = klass.new([1, 2, 3])
      e = impl.map!
      e.each do |el|
        el ** 2
      end
      assert_equal([1, 4, 9], impl)
      assert_equal(3, impl.size)
    end
  end

  def test_compact!
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, nil, 2, nil, 3, nil])
      assert_same(impl, impl.compact!)
      assert_equal([1, 2, 3], impl)
      assert_equal(3, impl.size)
      assert_equal(nil, impl.compact!)
      assert_equal([1, 2, 3], impl)
      assert_equal(3, impl.size)
    end
  end

  def test_delete
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 2.0, 1])
      assert_equal(2, impl.delete(2))
      assert_equal([1, 3, 1], impl)
      assert_equal(3, impl.size)

      impl = klass.new([1, 2.0, 3, 2.0, 1])
      assert_equal(2, impl.delete(2))
      assert_equal([1, 3, 1], impl)
      assert_equal(3, impl.size)

      assert_equal(nil, impl.delete(2))
      assert_equal([1, 3, 1], impl)
      assert_equal(3, impl.size)

      impl = klass.new([1, 2.0, 3, 2.0, 1])
      assert_equal(2, impl.delete(2) { "foo" * 2 })
      assert_equal([1, 3, 1], impl)
      assert_equal(3, impl.size)

      assert_equal("barbar", impl.delete(2) { "bar" * 2 })
      assert_equal([1, 3, 1], impl)
      assert_equal(3, impl.size)
    end
  end

  def test_delete_at
    FULL_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal(2, impl.delete_at(1), msg)
      assert_equal([1, 3, 4, 5], impl, msg)
      assert_equal(4, impl.size, msg)

      assert_equal(1, impl.delete_at(-4), msg)
      assert_equal([3, 4, 5], impl, msg)
      assert_equal(3, impl.size, msg)

      assert_equal(nil, impl.delete_at(-4), msg)
      assert_equal([3, 4, 5], impl, msg)
      assert_equal(3, impl.size, msg)
      assert_equal(nil, impl.delete_at(3), msg)
      assert_equal([3, 4, 5], impl, msg)
      assert_equal(3, impl.size, msg)
    end
  end

  def test_delete_if
    FULL_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([1, 2, 3, 4, 5])
      assert_same(impl, impl.delete_if { |x| x % 2 != 0 }, msg)
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)
      assert_same(impl, impl.delete_if { |x| x % 2 != 0 }, msg)
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      e = impl.delete_if
      e.each { |x| x % 2 != 0 }
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)
    end
  end

  def test_reject!
    FULL_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([1, 2, 3, 4, 5])
      assert_same(impl, impl.reject! { |x| x % 2 != 0 }, msg)
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)
      assert_same(nil, impl.reject! { |x| x % 2 != 0 }, msg)
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      e = impl.reject!
      e.each { |x| x % 2 != 0 }
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)
    end
  end

  # TODO: Delete me.
  def test_fill_start_length
    FULL_IMPLS.each do |klass|
      impl = klass.new([0, 1, 2, 3 ,4])
      impl.fill(-1, 0, 3)
      assert_equal([-1, -1, -1, 3, 4], impl)
      assert_equal(5, impl.size)

      impl = klass.new([0, 1, 2, 3 ,4])
      impl.fill(-1, 2, 3)
      assert_equal([0, 1, -1, -1, -1], impl)
      assert_equal(5, impl.size)

      impl = klass.new([0, 1, 2, 3 ,4])
      impl.fill(-1, 2, 5)
      assert_equal([0, 1, -1, -1, -1, -1, -1], impl)
      assert_equal(7, impl.size)

      impl = klass.new([0, 1, 2, 3 ,4])
      impl.fill(-1, 7, 3)
      assert_equal([0, 1, 2, 3, 4, nil, nil, -1, -1, -1], impl)
      assert_equal(10, impl.size)
    end
  end

  def test_flatten!
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, [2, 3, [4], 5]])
      assert_same(impl, impl.flatten!(1))
      assert_equal([1, 2, 3, [4], 5], impl)
      assert_equal(5, impl.size)

      impl = klass.new([1, 2, 3])
      assert_equal(nil, impl.flatten!)
      assert_equal([1, 2, 3], impl)
      assert_equal(3, impl.size)
    end
  end

  def test_keep_if
    FULL_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([1, 2, 3, 4, 5])
      impl.keep_if { |x| x % 2 == 0 }
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)
      impl.keep_if { |x| x % 2 == 0 }
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      e = impl.keep_if
      e.each { |x| x % 2 == 0 }
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)
    end
  end

  def test_pop
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal(5, impl.pop)
      assert_equal([1, 2, 3, 4], impl)
      assert_equal(4, impl.size)

      assert_equal([3, 4], impl.pop(2))
      assert_equal([1, 2], impl)
      assert_equal(2, impl.size)

      assert_equal([1, 2], impl.pop(3))
      assert_equal([], impl)
      assert_equal(0, impl.size)

      assert_equal(nil, impl.pop)
      assert_equal([], impl)
      assert_equal(0, impl.size)

      assert_equal([], impl.pop(3))
      assert_equal([], impl)
      assert_equal(0, impl.size)
    end
  end

  def test_push
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      impl.push(-1)
      assert_equal([1, 2, 3, -1], impl)
      assert_equal(4, impl.size)
      
      impl.push(-2, -3)
      assert_equal([1, 2, 3, -1, -2, -3], impl)
      assert_equal(6, impl.size)
    end
  end

  def test_reverse!
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_same(impl, impl.reverse!)
      assert_equal([3, 2, 1], impl)
      assert_equal(3, impl.size)
    end
  end

  def test_rotate!
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4])
      impl.rotate!
      assert_equal([2, 3, 4, 1], impl)
      impl.rotate!(2)
      assert_equal([4, 1, 2, 3], impl)
      impl.rotate!(-3)
      assert_equal([1, 2, 3, 4], impl)
    end
  end

  def test_select!
    FULL_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([1, 2, 3, 4, 5])
      impl.select! { |x| x % 2 == 0 }
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)
      impl.select! { |x| x % 2 == 0 }
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      e = impl.select!
      e.each { |x| x % 2 == 0 }
      assert_equal([2, 4], impl, msg)
      assert_equal(2, impl.size, msg)
    end
  end

  def test_shuffle!
    FULL_IMPLS.each do |klass|
      orig = [1, 2, 3, 4, 5]
      impl = klass.new(orig.clone)
      res = 10000.times do
        impl.shuffle!
        break false if orig != impl
      end
      assert(!res, "#{klass.name}#shuffle! failed.")
      assert_equal(5, impl.size)
      impl.sort!
      assert_equal([1, 2, 3, 4, 5], impl)
    end
  end

  def test_slice_pos!
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_equal(2, impl.slice!(1))
      assert_equal([1, 3], impl)
      assert_equal(2, impl.size)

      assert_equal(3, impl.slice!(-1))
      assert_equal([1], impl)
      assert_equal(1, impl.size)

      assert_equal(nil, impl.slice!(100))
      assert_equal([1], impl)
      assert_equal(1, impl.size)
    end
  end

  def test_slice_range!
    FULL_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal([2, 3], impl.slice!(1..2), msg)
      assert_equal([1, 4, 5], impl, msg)
      assert_equal(3, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal([], impl.slice!(5..6), msg)
      assert_equal([1, 2, 3, 4, 5], impl, msg)
      assert_equal(5, impl.size, msg)
      
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal(nil, impl.slice!(6..100), msg)
      assert_equal([1, 2, 3, 4, 5], impl, msg)
      assert_equal(5, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal([2, 3], impl.slice!(1...3), msg)
      assert_equal([1, 4, 5], impl, msg)
      assert_equal(3, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal([], impl.slice!(5...7), msg)
      assert_equal([1, 2, 3, 4, 5], impl, msg)
      assert_equal(5, impl.size, msg)
      
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal(nil, impl.slice!(6...100), msg)
      assert_equal([1, 2, 3, 4, 5], impl, msg)
      assert_equal(5, impl.size, msg)
    end
  end

  def test_shift
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal(1, impl.shift)
      assert_equal([2, 3, 4, 5], impl)
      assert_equal(4, impl.size)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal([1, 2, 3], impl.shift(3))
      assert_equal([4, 5], impl)
      assert_equal(2, impl.size)
      
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal([1, 2, 3, 4, 5], impl.shift(8))
      assert_equal([], impl)
      assert_equal(0, impl.size)

      impl = klass.new([])
      assert_equal(nil, impl.shift)
      assert_equal([], impl.shift(1))
      assert_equal([], impl)
      assert_equal(0, impl.size)
    end
  end

  def test_sort!
    FULL_IMPLS.each do |klass|
      impl = klass.new([27, 14, 45, 3, 11])
      assert_same(impl, impl.sort!)
      assert_equal([3, 11, 14, 27, 45], impl)
      assert_equal(5, impl.size)

      assert_same(impl, impl.sort! { |a, b| a % 5 <=> b % 5})
      assert_equal([45, 11, 27, 3, 14], impl)
      assert_equal(5, impl.size)
    end
  end

  def test_sort_by!
    FULL_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([27, 14, 45, 3, 11])
      e = impl.sort_by!
      e.each { |a| -a }
      assert_equal([45, 27, 14, 11, 3], impl)
      assert_equal(5, impl.size)

      impl = klass.new([27, 14, 45, 3, 11])
      assert_same(impl, impl.sort_by! { |a| a % 5 })
      assert_equal([45, 11, 27, 3, 14], impl)
      assert_equal(5, impl.size)
    end
  end

  def test_uniq!
    FULL_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([1, 3, 2, 2, 3])
      assert_same(impl, impl.uniq!, msg)
      assert_equal([1, 3, 2], impl, msg)
      assert_equal(3, impl.size, msg)
      assert_equal(nil, impl.uniq!, msg)
      assert_equal([1, 3, 2], impl, msg)
      assert_equal(3, impl.size, msg)

      impl = klass.new([1, -3, 2, -2, 3])
      assert_same(impl, impl.uniq! { |n| n.abs }, msg)
      assert_equal([1, -3, 2], impl, msg)
      assert_equal(3, impl.size, msg)
      assert_equal(nil, impl.uniq! { |n| n.abs }, msg)
      assert_equal([1, -3, 2], impl, msg)
      assert_equal(3, impl.size, msg)
    end
  end

  def test_unshift
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      impl.unshift(-1)
      assert_equal([-1, 1, 2, 3], impl)
      assert_equal(4, impl.size)
    end
  end

end
