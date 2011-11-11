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
      msg = "Error in #{klass.name}"

      assert_equal(nil, impl[-12..-11], msg)
      assert_equal(nil, impl[-14..-10], msg)
      assert_equal([0, 1, 2], impl[-10..-8], msg)
      assert_equal([8, 9], impl[-2..-1], msg)
      assert_equal([1, 2, 3], impl[-9..3], msg)
      assert_equal([0, 1], impl[0..1], msg)
      assert_equal([8, 9], impl[8..9], msg)
      assert_equal([8, 9], impl[8..100], msg)
      assert_equal([], impl[10..15], msg)
      assert_equal(nil, impl[11..15], msg)
      assert_equal([], impl[-1..-2], msg)
      assert_equal([], impl[3..0], msg)
      assert_equal([], impl[-1..1], msg)
      assert_equal(nil, impl[15..14], msg)
      assert_equal(nil, impl[-11..-20], msg)
      assert_equal(nil, impl[15..5], msg)
      assert_equal([], impl[-10..-20],msg)

      assert_equal(nil, impl[-12...-10], msg)
      assert_equal(nil, impl[-14...-9], msg)
      assert_equal([0, 1, 2], impl[-10...-7], msg)
      assert_equal([], impl[-2...0], msg)
      assert_equal([1, 2, 3], impl[-9...4], msg)
      assert_equal([0, 1], impl[0...2], msg)
      assert_equal([8, 9], impl[8...10], msg)
      assert_equal([8, 9], impl[8...100], msg)
      assert_equal([], impl[10...15], msg)
      assert_equal(nil, impl[11...15], msg)
      assert_equal([], impl[-1...-1], msg)
      assert_equal([], impl[0...0], msg)
      assert_equal([3, 4, 5, 6, 7, 8], impl[3...-1], msg)
      assert_equal([], impl[-1...2], msg)
      assert_equal(nil, impl[16...15], msg)
      assert_equal(nil, impl[-11...-20], msg)
      assert_equal(nil, impl[15...5], msg)
      assert_equal([], impl[-10...-20], msg)
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

  def test_assoc
    FULL_IMPLS.each do |klass|
      impl = klass.new([[1,15], [2,25], [3,35]])
      assert_equal([1, 15], impl.assoc(1))
      assert_equal([2, 25], impl.assoc(2))
      assert_equal([3, 35], impl.assoc(3))
      assert_nil(impl.assoc(100))
      assert_nil(impl.assoc(15))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([[1,15], [2,25], [3,35]])
      assert_equal([1, 15], impl.assoc(1))
      assert_equal([2, 25], impl.assoc(2))
      assert_equal([3, 35], impl.assoc(3))
      [100, 15].each do |n|
        assert_raise ErrorForTest do
          impl.assoc(n)
        end
      end
    end
  end

  def test_at
    FULL_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      assert_nil(impl.at(-11))
      assert_equal(0, impl.at(-10))
      assert_equal(9, impl.at(-1))
      assert_equal(0, impl.at(0))
      assert_equal(9, impl.at(9))
      assert_nil(impl.at(10))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      [-11, -10, -1].each do |pos|
        assert_raise NotImplementedError do
          impl.at(pos)
        end
      end

      assert_equal(0, impl.at(0))
      assert_equal(9, impl.at(9))

      assert_raise ErrorForTest do
        impl.at(10)
      end
    end
  end

  def test_combination
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4])
      assert_equal([], impl.combination(-1).to_a)
      assert_equal([[]], impl.combination(0).to_a)
      assert_equal([[1],[2],[3],[4]], impl.combination(1).to_a)
      assert_equal([[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]],
                   impl.combination(2).to_a)
      assert_equal([[1,2,3],[1,2,4],[1,3,4],[2,3,4]],
                   impl.combination(3).to_a)
      assert_equal([[1,2,3,4]], impl.combination(4).to_a)
      assert_equal([], impl.combination(5).to_a)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4])
      (-1..5).each do |i|
        assert_raise NotImplementedError do
          impl.combination(i)
        end
      end
    end
  end

  def test_compact
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, nil, 2, nil, 3, nil])
      assert_equal([1, 2, 3], impl.compact)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, nil, 2, nil, 3, nil])
      assert_raise NotImplementedError do
        impl.compact
      end
    end
  end

  def test_cycle
    FULL_IMPLS.each do |klass|
      impl = klass.new([0, 1, 2])
      i = 0
      impl.cycle do |el|
        assert_equal(i % 3, el)
        i += 1
        break if i > 100
      end
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([0, 1, 2])
      i = 0
      assert_raise ErrorForTest do
        impl.cycle do |el|
          if i < 3
            assert_equal(i, el)
          end
          i += 1
        end
      end
    end
  end

  def test_each
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 4, 9, 16])
      i = 1
      impl.each do |el|
        assert_equal(i * i, el)
        i += 1
      end
      assert_equal(4, i - 1)
      assert_equal([1, 4, 9, 16], impl.each.to_a)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise NotImplementedError do
        impl.each.next
      end
      assert_raise NotImplementedError do
        impl.each do
          assert_fail
        end
      end
    end
  end

  def test_each_index
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4, 5])
      n = 0
      impl.each_index do |i|
        assert_equal(n, i)
        n += 1
      end
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise NotImplementedError do
        impl.each_index do
          assert_fail
        end
      end
    end
  end

  def test_empty
    FULL_IMPLS.each do |klass|
      impl = klass.new([])
      assert_equal(true, impl.empty?)

      impl = klass.new([1])
      assert_equal(false, impl.empty?)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_equal(false, impl.empty?)
    end
  end

  def test_eql?
    FULL_IMPLS.each do |klass|
      next if klass == Array

      impl1 = klass.new(["a", "b", "c"])
      impl2 = klass.new(["a", "b", "c"])
      assert_equal(true, impl1.eql?(impl2))

      assert_equal(false, impl1.eql?(["a", "b", "c"]))
      assert_equal(false, ["a", "b", "c"].eql?(impl1))

      impl1 = klass.new(["a", "b", "c"])
      impl2 = klass.new(["a", "b", "d"])
      assert_equal(false, impl1.eql?(impl2))

      impl1 = klass.new(["a", "b", 1])
      impl2 = klass.new(["a", "b", 1.0])
      assert_equal(false, impl1.eql?(impl2))
    end
    NOSIZE_IMPLS.each do |klass|
      impl1 = klass.new(["a", "b", "c"])
      impl2 = klass.new(["a", "b", "c"])
      assert_equal(false, impl1.eql?(impl2))
      assert_equal(true, impl1.eql?(impl1))
    end
  end

  def test_fetch
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])

      assert_equal(1, impl.fetch(-3))
      assert_equal(3, impl.fetch(-1))
      assert_equal(1, impl.fetch(0))
      assert_equal(3, impl.fetch(2))

      [-4, 3].each do |i|
        assert_raise IndexError do
          impl.fetch(i)
        end
      end

      assert_equal(-1, impl.fetch(-4, -1))
      assert_equal(1, impl.fetch(-3, -1))
      assert_equal(3, impl.fetch(-1, -1))
      assert_equal(1, impl.fetch(0, -1))
      assert_equal(3, impl.fetch(2, -1))
      assert_equal(-1, impl.fetch(3, -1))

      assert_equal(-1, impl.fetch(-4) { -1 })
      assert_equal(1, impl.fetch(-3) { -1 })
      assert_equal(3, impl.fetch(-1) { -1 })
      assert_equal(1, impl.fetch(0) { -1 })
      assert_equal(3, impl.fetch(2) { -1 })
      assert_equal(-1, impl.fetch(3) { -1 })
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])

      assert_equal(1, impl.fetch(0))
      assert_equal(3, impl.fetch(2))

      assert_equal(1, impl.fetch(0, -1))
      assert_equal(3, impl.fetch(2, -1))

      assert_equal(1, impl.fetch(0) { -1 })
      assert_equal(3, impl.fetch(2) { -1 })

      [-4, -3, -1].each do |i|
        assert_raise NotImplementedError do
          impl.fetch(i)
        end
        assert_raise NotImplementedError do
          impl.fetch(i, -1)
        end
        assert_raise NotImplementedError do
          impl.fetch(i) { -1 }
        end
      end

      assert_raise ErrorForTest do
        impl.fetch(3)
      end
      assert_raise ErrorForTest do
        impl.fetch(3, -1)
      end
      assert_raise ErrorForTest do
        impl.fetch(3) { -1 }
      end
    end
  end

  def test_first
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_equal(1, impl.first)
      assert_equal([], impl.first(0))
      assert_equal([1], impl.first(1))
      assert_equal([1, 2], impl.first(2))
      assert_equal([1, 2, 3], impl.first(3))
      assert_equal([1, 2, 3], impl.first(4))

      impl = klass.new([])
      assert_equal(nil, impl.first)
      assert_equal([], impl.first(0))
      assert_equal([], impl.first(1))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_equal(1, impl.first)
      assert_equal([], impl.first(0))
      assert_equal([1], impl.first(1))
      assert_equal([1, 2], impl.first(2))
      assert_equal([1, 2, 3], impl.first(3))
      assert_raise ErrorForTest do 
        impl.first(4)
      end

      impl = klass.new([])
      assert_raise(ErrorForTest) { impl.first }
      assert_equal([], impl.first(0))
      assert_raise(ErrorForTest) { impl.first(1) }
    end
  end

  def test_foo
    FULL_IMPLS.each do |klass|
    end
    NOSIZE_IMPLS.each do |klass|
    end
  end

  def test_foo
    FULL_IMPLS.each do |klass|
    end
    NOSIZE_IMPLS.each do |klass|
    end
  end

  def test_foo
    FULL_IMPLS.each do |klass|
    end
    NOSIZE_IMPLS.each do |klass|
    end
  end

end

