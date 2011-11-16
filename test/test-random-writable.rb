require 'test/unit'
require 'random-writable'

class ErrorForTest < Exception
end

class Reference < Array
end

class WriteAccessAndExpand

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

class WriteAccessAndExpandAndSize < WriteAccessAndExpand

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

class WriteAccessAndExpandAndDeleteAccessAndSize < WriteAccessAndExpandAndSize

  def delete_access(pos)
    @a.delete_at(pos)
    @size -= 1
  end

end

NOSIZE_IMPLS = [WriteAccessAndExpand]
FULL_IMPLS   = [Array,
                WriteAccessAndExpandAndDeleteAccessAndSize]

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
  def test_foo
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
    end
  end
  
end
