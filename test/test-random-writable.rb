require 'test/unit'
require 'random-writable'

class ErrorForTest < Exception
end

class Reference < Array
end

class WriExp

  include RandomWritable

  def initialize(ary = [])
    @a = ary
    @size = ary.size
  end

  def to_ary
    @a.clone
  end

  def expand(n)
    @size += n
  end

  def trim(n)
    @a.pop(n)
    @size -= n
  end

  def replace_access(pos, val)
    if pos < 0
      raise ErrorForTest, "size=#{@size} pos=#{pos}"
    end
    @a[pos.to_int] = val
  end

end

class WriExpSiz < WriExp

  def size
    @size
  end

  def replace_access(pos, val)
    if @size <= pos
      raise ErrorForTest, "size=#{@size} pos=#{pos}"
    end
    super
  end

end

class WriExpDelIns < WriExp

  def delete_access(pos)
    if pos < 0 || @a.size <= pos
      raise ErrorForTest, "@a.size=#{@a.size} but pos=#{pos}"
    end
    @a.delete_at(pos)
    @size -= 1
    return "retval of delete_access"
  end

  def insert_access(pos, val)
    raise ErrorForTest if pos < 0
    @a.insert(pos, val)
    @size += 1
  end

end

class WriExpDelInsSiz < WriExpSiz

  def delete_access(pos)
    raise ErrorForTest if pos < 0 || @size <= pos
    @a.delete_at(pos)
    @size -= 1
    return "retval of delete_access"
  end

  def insert_access(pos, val)
    raise ErrorForTest if pos < 0 || @size <= pos
    @a.insert(pos, val)
    @size += 1
  end

end

class FixedArray < Array

  def delete_at(pos)
    s = size
    super
    if pos < -s || s <= pos
      return nil
    else
      return "retval of delete_access"
    end
  end

end


NOSIZE_IMPLS = [WriExpDelIns]
NODELETE_IMPLS = [WriExpSiz]
FULL_IMPLS   = [FixedArray,
                WriExpDelInsSiz]

class TestRandomWritable < Test::Unit::TestCase

  def test_lshift
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2])
      impl << 3 << 4 << 5
      assert_equal([1, 2, 3 ,4 ,5], impl.to_ary)
      assert_equal(5, impl.size)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise NotImplementedError do
        impl << 0
      end
    end
  end

  def test_bracket_pos
    FULL_IMPLS.each do |klass|
      impl = klass.new([0, 1, 2, 3, 4, 5])
      impl[0] = "a"
      assert_equal(["a", 1, 2, 3, 4, 5], impl.to_ary)
      assert_equal(6, impl.size)
      impl[3] = 3.5
      assert_equal(["a", 1, 2, 3.5, 4, 5], impl.to_ary)
      assert_equal(6, impl.size)
      impl[10] = nil
      assert_equal(["a", 1, 2, 3.5, 4, 5, nil, nil, nil, nil, nil],
                   impl.to_ary)
      assert_equal(11, impl.size)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([0, 1, 2, 3, 4, 5])
      impl[0] = "a"
      assert_equal(["a", 1, 2, 3, 4, 5], impl.to_ary)
      impl[3] = 3.5
      assert_equal(["a", 1, 2, 3.5, 4, 5], impl.to_ary)
      impl[10] = nil
      assert_equal(["a", 1, 2, 3.5, 4, 5, nil, nil, nil, nil, nil],
                   impl.to_ary)
    end
  end

  def test_bracket_range
    FULL_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([0, 1, 2, 3, 4, 5])

      impl[0..2] = ["a", "b"]
      assert_equal(["a", "b", 3, 4, 5], impl.to_ary, msg)
      assert_equal(5, impl.size, msg)

      impl[1..3] = 3.5
      assert_equal(["a", 3.5, 5], impl.to_ary, msg)
      assert_equal(3, impl.size, msg)

      impl[5..10] = nil
      assert_equal(["a", 3.5, 5, nil, nil, nil],
                   impl.to_ary, msg)
      assert_equal(6, impl.size, msg)

      impl[2..3] = [-1, -2, -3]
      assert_equal(["a", 3.5, -1, -2, -3, nil, nil],
                   impl.to_ary, msg)
      assert_equal(7, impl.size, msg)
    end
    NODELETE_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([0, 1, 2, 3, 4, 5])
      impl[0..1] = ["a", "b"]
      assert_equal(["a", "b", 2, 3, 4, 5], impl.to_ary, msg)
      assert_equal(6, impl.size, msg)

      impl[1..1] = 3.5
      assert_equal(["a", 3.5, 2, 3, 4, 5], impl.to_ary, msg)
      assert_equal(6, impl.size, msg)

      impl[7..10] = 7
      assert_equal(["a", 3.5, 2, 3, 4, 5, nil, 7],
                   impl.to_ary, msg)
      assert_equal(8, impl.size, msg)

      assert_raise(NotImplementedError) { impl[0..1] = 0 }
      assert_raise(NotImplementedError) { impl[1..3] = [1, 2] }
      assert_equal(["a", 3.5, 2, 3, 4, 5, nil, 7],
                   impl.to_ary, msg)
      assert_equal(8, impl.size, msg)
    end
    NOSIZE_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"
      impl = klass.new([0, 1, 2, 3, 4, 5])
      impl[0..2] = ["a", "b"]
      assert_equal(["a", "b", 3, 4, 5], impl.to_ary, msg)
      impl[1..3] = 3.5
      assert_equal(["a", 3.5, 5], impl.to_ary, msg)
      assert_raise(ErrorForTest, msg) { impl[5..10] = nil }
      assert_equal(["a", 3.5, 5], impl.to_ary, msg)
    end
  end

  def test_clear
    FULL_IMPLS.each do |klass|
      impl = klass.new((1..100).to_a)
      impl.clear
      assert_equal([], impl.to_ary)
      assert_equal(0, impl.size)
    end
    NODELETE_IMPLS.each do |klass|
      impl = klass.new((1..100).to_a)
      impl.clear
      assert_equal([], impl.to_ary)
      assert_equal(0, impl.size)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new((1..100).to_a)
      assert_raise(NotImplementedError) { impl.clear }
    end
  end

  def test_concat
    (FULL_IMPLS + NODELETE_IMPLS).each do |klass|
      impl = klass.new([1, 2, 3])
      impl.concat([4, 5])
      assert_equal([1, 2, 3, 4, 5], impl.to_ary)
      assert_equal(5, impl.size)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_raise(NotImplementedError) { impl.concat([4, 5]) }
    end
  end

  def test_delete_at
    FULL_IMPLS.each do |klass|
      msg = "Error in #{klass.name}"

      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal("retval of delete_access", impl.delete_at(0), msg)
      assert_equal([2, 3, 4, 5], impl.to_ary, msg)
      assert_equal(4, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal("retval of delete_access", impl.delete_at(4), msg)
      assert_equal([1, 2, 3, 4], impl.to_ary, msg)
      assert_equal(4, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal("retval of delete_access", impl.delete_at(-1), msg)
      assert_equal([1, 2, 3, 4], impl.to_ary, msg)
      assert_equal(4, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal("retval of delete_access", impl.delete_at(-5), msg)
      assert_equal([2, 3, 4, 5], impl.to_ary, msg)
      assert_equal(4, impl.size, msg)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal(nil, impl.delete_at(-7), msg)
      assert_equal(nil, impl.delete_at(-6), msg)
      assert_equal(nil, impl.delete_at(5), msg)
      assert_equal(nil, impl.delete_at(6), msg)
      assert_equal([1, 2, 3, 4, 5], impl.to_ary, msg)
      assert_equal(5, impl.size, msg)
    end
    NODELETE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal(nil, impl.delete_at(-7))
      assert_equal(nil, impl.delete_at(-6))
      assert_raise(NotImplementedError) { impl.delete_at(-5) }
      assert_raise(NotImplementedError) { impl.delete_at(-1) }
      assert_raise(NotImplementedError) { impl.delete_at(0) }
      assert_raise(NotImplementedError) { impl.delete_at(4) }
      assert_equal(nil, impl.delete_at(5))
      assert_equal(nil, impl.delete_at(6))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal("retval of delete_access", impl.delete_at(0))
      assert_equal([2, 3, 4, 5], impl.to_ary)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal("retval of delete_access", impl.delete_at(4))
      assert_equal([1, 2, 3, 4], impl.to_ary)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_raise(NotImplementedError) { impl.delete_at(-1) }
      assert_equal([1, 2, 3, 4, 5], impl.to_ary)

      assert_raise(NotImplementedError) { impl.delete_at(-5) }
      assert_equal([1, 2, 3, 4, 5], impl.to_ary)

      assert_raise(NotImplementedError) { impl.delete_at(-6) }
      assert_equal([1, 2, 3, 4, 5], impl.to_ary)

      impl = klass.new([1, 2, 3, 4, 5])
      assert_raise(ErrorForTest) { impl.delete_at(5) }
      assert_raise(ErrorForTest) { impl.delete_at(6) }
      assert_equal([1, 2, 3, 4, 5], impl.to_ary)
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NODELETE_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NODELETE_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NODELETE_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NODELETE_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  
end
