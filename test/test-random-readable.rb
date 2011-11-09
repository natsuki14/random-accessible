require 'test/unit'
require 'random-readable'

class ErrorForTest < Exception
end

class ReadAccess

  include RandomReadable

  def initialize(ary)
    @a = ary
  end

  def read_access(pos)
    raise ErrorForTest if pos < 0 || @a.size <= pos
    @a[pos.to_int]
  end

end

class ReadAccessAndSize

  include RandomReadable

  def initialize(ary)
    @a = ary
  end

  def read_access(pos)
    raise ErrorForTest if pos < 0 || @a.size <= pos
    @a[pos.to_int]
  end

  def size
    @a.size
  end

end

NOSIZE_IMPLS = [ReadAccess]
FULL_IMPLS = [Array, # To test test cases.
              ReadAccessAndSize]

class TestReadAccessable < Test::Unit::TestCase

  def test_size_not_implemented
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise NotImplementedError do
        impl.size
      end
      assert_raise NotImplementedError do
      impl.length
      end
    end
  end

  def test_ampersand
    FULL_IMPLS.each do |klass|
      impl1 = klass.new([1, 1, 2, 3])
      impl2 = klass.new([1, 3, 4])

      assert_equal([1, 3], impl1 & impl2)
      assert_equal([1, 3], impl1 & [1, 3, 4])
    end
    NOSIZE_IMPLS.each do |klass|
      assert_raise NotImplementedError do
        klass.new([]) & []
      end
    end
  end

  def test_asterisk_times
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_equal([1, 2, 3] * 3, impl * 3)
    end
    NOSIZE_IMPLS.each do |klass|
      assert_raise NotImplementedError do
        klass.new([]) * []
      end
    end
  end

  def test_asterisk_separator
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_equal([1, 2, 3] * 'foo', impl * 'foo')
    end
    NOSIZE_IMPLS.each do |klass|
      assert_raise NotImplementedError do
        klass.new([]) * 'bar'
      end
    end
  end

  def test_plus
    FULL_IMPLS.each do |klass|
      impl1 = klass.new([1, 2])
      impl2 = klass.new([8, 9])
      assert_equal([1, 2, 8, 9], impl1 + impl2)
      assert_equal([1, 2], impl1)
      assert_equal([8, 9], impl2)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise NotImplementedError do
        impl + impl
      end
    end
  end

  def test_minus
    FULL_IMPLS.each do |klass|
      impl1 = klass.new([1, 2, 1, 3, 1, 4, 1, 5])
      impl2 = klass.new([2, 3, 4, 5])
      assert_equal([1, 1, 1, 1], impl1 - impl2)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise NotImplementedError do
        impl - impl
      end
    end
  end

  def test_compare
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_equal(-1, impl <=> [1, 3, 2])
      assert_equal(1,  impl <=> [1, 0, 3])
      assert_equal(0,  impl <=> [1, 2, 3])
      assert_equal(1,  [1, 3, 2] <=> impl)
      assert_equal(-1, [1, 0, 3] <=> impl)
      assert_equal(0,  [1, 2, 3] <=> impl)
      assert_equal(-1, impl <=> [1, 2, 3, 4])
      assert_equal(1,  [1, 2, 3, 4] <=> impl)
      assert_equal(1,  impl <=> [1, 2])
      assert_equal(-1, [1, 2] <=> impl)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise NotImplementedError do
        impl <=> []
      end
      assert_raise NotImplementedError do
        [] <=> impl
      end
    end
  end

  def test_equal
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert(impl == [1, 2, 3])
      assert(impl == [1.0, 2.0, 3.0])
      assert(impl != [1, 2, 3, 4])
      assert(impl != [1, 2])
      assert(impl != [1, 2, 3.01])
      assert(impl != [1.01, 2, 3])
    end
    NOSIZE_IMPLS.each do |klass|
      impl1 = klass.new([1, 2])
      impl2 = klass.new([1, 2])
      assert(impl1 == impl1)
      assert(impl1 != impl2)
      assert(impl1 != [1, 2])
      assert([1, 2] != impl1)
    end
  end

  def test_bracket_position
    FULL_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      assert_nil(impl[-11])
      assert_equal(0, impl[-10])
      assert_equal(9, impl[-1])
      assert_equal(0, impl[0])
      assert_equal(9, impl[9])
      assert_nil(impl[10])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      [-11, -10, -1].each do |pos|
        assert_raise NotImplementedError do
          impl[pos]
        end
      end

      assert_equal(0, impl[0])
      assert_equal(9, impl[9])

      assert_raise ErrorForTest do
        impl[10]
      end
    end
  end

  def test_bracket_range
    FULL_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      assert_equal(nil, impl[-12..-11])
      assert_equal(nil, impl[-14..-10])
      assert_equal([0, 1, 2], impl[-10..-8])
      assert_equal([8, 9], impl[-2..-1])
      assert_equal([1, 2, 3], impl[-9..3])
      assert_equal([0, 1], impl[0..1])
      assert_equal([8, 9], impl[8..9])
      assert_equal([8, 9], impl[8..100])
      assert_equal([], impl[10..15])
      assert_equal(nil, impl[11..15])
      assert_equal([], impl[-1..-2])
      assert_equal([], impl[3..0])
      assert_equal([], impl[-1..1])
      assert_equal(nil, impl[15..14])
      assert_equal(nil, impl[-11..-20])
      assert_equal(nil, impl[15..5])
      assert_equal([], impl[-10..-20])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      [-12..-11, -14..-10, -10..-8, -2..-1, -1..1].each do |range|
        assert_raise NotImplementedError do
          impl[range]
        end
      end

      assert_equal([0, 1], impl[0..1])
      assert_equal([8, 9], impl[8..9])
      assert_equal([], impl[15..10])
      assert_equal([], impl[-1..-2])

      [8..11, 10..15].each do |range|
        assert_raise ErrorForTest do
          impl[range]
        end
      end
    end
  end

  def test_bracket_start_and_length
    FULL_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      assert_equal(nil, impl[-12, 2])
      assert_equal(nil, impl[-14, 5])
      assert_equal([0, 1, 2], impl[-10, 3])
      assert_equal([8, 9], impl[-2, 2])
      assert_equal([1, 2, 3], impl[-9, 3])
      assert_equal([0, 1], impl[0, 2])
      assert_equal([5], impl[5, 1])
      assert_equal([8, 9], impl[8, 2])
      assert_equal([8, 9], impl[8, 100])
      assert_equal([], impl[10, 5])
      assert_equal(nil, impl[11, 15])
      assert_equal(nil, impl[-1, -2], "Error in #{klass.name}")
      assert_equal(nil, impl[3, -3])
      assert_equal(nil, impl[15, -1])
      assert_equal(nil, impl[-11, -20])
      assert_equal(nil, impl[15, -10])
      assert_equal(nil, impl[-10, -20])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      [[-12, 2], [-14, 5], [-10, 3], [-2, 2], [-1, 3]].each do |range|
        assert_raise NotImplementedError do
          impl[*range]
        end
      end

      assert_equal([0, 1], impl[0, 2])
      assert_equal([8, 9], impl[8, 2])
      assert_equal([], impl[15, -6])
      assert_equal([], impl[-1, -2])

      [[8, 4], [10, 6]].each do |range|
        assert_raise ErrorForTest do
          impl[*range]
        end
      end
    end
  end

end

