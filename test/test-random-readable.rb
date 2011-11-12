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

class ReadAccessAndLength

  include RandomReadable

  def initialize(ary)
    @a = ary
  end

  def read_access(pos)
    raise ErrorForTest if pos < 0 || @a.size <= pos
    @a[pos.to_int]
  end

  def length
    @a.length
  end

end

NOSIZE_IMPLS = [ReadAccess]
FULL_IMPLS = [Array, # To test test cases.
              ReadAccessAndSize,
              ReadAccessAndLength]

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
      assert_equal([], impl[-10..-20], msg)
      assert_equal([], impl[1..-20], msg)

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
      assert_equal([], impl[1...-20], msg)
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

  def test_flatten
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, [2, 3, [4], 5]])
      assert_equal([1, 2, 3, 4, 5], impl.flatten)
      assert_equal([1, 2, 3, [4], 5], impl.flatten(1))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, [2, 3, [4], 5]])
      assert_raise(NotImplementedError) { impl.flatten }
      assert_raise(NotImplementedError) { impl.flatten(1) }
    end
  end

  def test_hash
    FULL_IMPLS.each do |klass|
      impl1 = klass.new([1, 2, 3, 4])
      impl2 = klass.new([1, 2, 3, 4])
      assert(impl1.hash == impl2.hash)

      # Assuming there is no collision.
      impl2 = klass.new([1, 2, 3, 3])
      assert(impl1.hash != impl2.hash)
    end
    NOSIZE_IMPLS.each do |klass|
      # Assuming there is no collision.
      impl1 = klass.new([1, 2, 3, 4])
      impl2 = klass.new([1, 2, 3, 4])
      assert(impl1.hash != impl2.hash)
    end
  end

  def test_include
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4.0])
      assert_equal(true, impl.include?(2))
      assert_equal(true, impl.include?(2.0))
      assert_equal(true, impl.include?(4))
      assert_equal(false, impl.include?(0))
      assert_equal(false, impl.include?(4.01))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4.0])
      assert_raise(NotImplementedError) { impl.include?(0) }
      assert_raise(NotImplementedError) { impl.include?(3) }
    end
  end

  def test_index
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4.0])
      assert_equal(1, impl.index(2))
      assert_equal(1, impl.index(2.0))
      assert_equal(3, impl.index(4))
      assert_equal(nil, impl.index(0))
      assert_equal(nil, impl.index(4.01))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4.0])
      assert_raise(NotImplementedError) { impl.index(0) }
      assert_raise(NotImplementedError) { impl.index(3) }
    end
  end

  def test_to_s_inspect
    FULL_IMPLS.each do |klass|
      ary = [1, "a", 2.0, [3], Hash.new([4])]
      impl = klass.new(ary)
      assert_equal(ary.to_s, impl.to_s)
      assert_equal(ary.inspect, impl.inspect)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, "a", 2.0, [3], Hash.new([4])])
      assert_nothing_raised do
        impl.to_s
        impl.inspect
      end
    end
  end

  def test_join
    FULL_IMPLS.each do |klass|
      ary = [1, "a", 2.0, [3], Hash.new([4])]
      impl = klass.new(ary)
      assert_equal(ary.join, impl.join)
      assert_equal(ary.join('foobar'), impl.join('foobar'))
      temp = $,
      $, = 'bazbaz'
      assert_equal(ary.join, impl.join)
      $, = temp
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, "a", 2.0, [3], Hash.new([4])])
      assert_raise(NotImplementedError) { impl.join }
      assert_raise(NotImplementedError) { impl.join('foobar') }
      temp = $,
      $, = 'bazbaz'
      assert_raise(NotImplementedError) { impl.join }
      $, = temp
    end
  end

  def test_last
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_equal(3, impl.last)
      assert_equal([], impl.last(0))
      assert_equal([3], impl.last(1))
      assert_equal([2, 3], impl.last(2))
      assert_equal([1, 2, 3], impl.last(3))
      assert_equal([1, 2, 3], impl.last(4))

      impl = klass.new([])
      assert_equal(nil, impl.last)
      assert_equal([], impl.last(0))
      assert_equal([], impl.last(1))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_raise(NotImplementedError) { impl.last }
      assert_raise(NotImplementedError) { impl.last(0) }
      assert_raise(NotImplementedError) { impl.last(1) }

      impl = klass.new([])
      assert_raise(NotImplementedError) { impl.last }
      assert_raise(NotImplementedError) { impl.last(0) }
      assert_raise(NotImplementedError) { impl.last(1) }
    end
  end

  def test_size_length
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_equal(3, impl.size)
      assert_equal(3, impl.length)

      impl = klass.new([])
      assert_equal(0, impl.size)
      assert_equal(0, impl.length)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_raise(NotImplementedError) { impl.size }
      assert_raise(NotImplementedError) { impl.length }

      impl = klass.new([])
      assert_raise(NotImplementedError) { impl.size }
      assert_raise(NotImplementedError) { impl.length }
    end
  end

  def test_pack
    # TODO
  end

  def test_permutation
    FULL_IMPLS.each do |klass|
      ary = [1, 2, 3, 4]
      impl = klass.new([1, 2, 3, 4])
      (-1..5).each do |i|
        ary_p = []
        impl_p = []
        ary.permutation(i) do |p|
          ary_p << p
        end
        impl.permutation(i) do |p|
          impl_p << p
        end
        assert_equal(ary_p.sort, impl_p.sort,
                     "Failed #{klass.name}\#permutation(#{i})")

        assert_equal(ary.permutation(i).to_a.sort,
                     impl.permutation(i).to_a.sort)
      end
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4])
      (-1..5).each do |i|
        assert_raise(NotImplementedError) { impl.permutation(i) }
      end
    end
  end

  def test_product
    FULL_IMPLS.each do |klass|
      ary = [1, 2, 3, 4]
      impl = klass.new([1, 2, 3, 4])
      [[[4, 5]], [[1, 2]], [[4, 5], [1, 2]]].each do |lists|
        ary_p = []
        impl_p = []
        ary.product(*lists) do |p|
          ary_p << p
        end
        impl.product(*lists) do |p|
          impl_p << p
        end
        assert_equal(ary_p.sort, impl_p.sort,
                     "Failed #{klass.name}\#product(#{lists.join(', ')}")

        assert_equal(ary.product(*lists).to_a.sort,
                     impl.product(*lists).to_a.sort)
      end
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4])
      [[[4, 5]], [[1, 2]], [[4, 5], [1, 2]]].each do |lists|
        assert_raise(NotImplementedError) { impl.product(*lists) }
      end
    end
  end

  def test_rassoc
    FULL_IMPLS.each do |klass|
      impl = klass.new([[15, 1], [25, 2], [35, 3]])
      msg = "Failed in #{klass.name}"
      assert_equal([15, 1], impl.rassoc(1), msg)
      assert_equal([25, 2], impl.rassoc(2), msg)
      assert_equal([25, 2], impl.rassoc(2.0), msg)
      assert_equal([35, 3], impl.rassoc(3), msg)
      
      assert_equal(nil, impl.rassoc(0), msg)
      assert_equal(nil, impl.rassoc(4), msg)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      (0..4).each do |i|
        assert_raise(NotImplementedError) { impl.rassoc(i) }
      end
    end
  end

  def test_repeated_combination
    FULL_IMPLS.each do |klass|
      ary = [1, 2, 3, 4]
      impl = klass.new([1, 2, 3, 4])
      (-1..5).each do |i|
        ary_p = []
        impl_p = []
        ary.repeated_combination(i) do |p|
          ary_p << p
        end
        impl.repeated_combination(i) do |p|
          impl_p << p
        end
        assert_equal(ary_p.sort, impl_p.sort,
                     "Failed #{klass.name}\#repeated_combination(#{i})")

        assert_equal(ary.repeated_combination(i).to_a.sort,
                     impl.repeated_combination(i).to_a.sort)
      end
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4])
      (-1..5).each do |i|
        assert_raise(NotImplementedError) { impl.repeated_combination(i) }
      end
    end
  end

  def test_repeated_permutation
    FULL_IMPLS.each do |klass|
      ary = [1, 2, 3, 4]
      impl = klass.new([1, 2, 3, 4])
      (-1..5).each do |i|
        ary_p = []
        impl_p = []
        ary.repeated_permutation(i) do |p|
          ary_p << p
        end
        impl.repeated_permutation(i) do |p|
          impl_p << p
        end
        assert_equal(ary_p.sort, impl_p.sort,
                     "Failed #{klass.name}\#repeated_permutation(#{i})")

        assert_equal(ary.repeated_permutation(i).to_a.sort,
                     impl.repeated_permutation(i).to_a.sort)
      end
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4])
      (-1..5).each do |i|
        assert_raise(NotImplementedError) { impl.repeated_permutation(i) }
      end
    end
  end

  def test_reverse
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4])
      assert_equal([4, 3, 2, 1], impl.reverse)

      impl = klass.new([])
      assert_equal([], impl.reverse)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise(NotImplementedError) { impl.reverse }
    end
  end

  def test_reverse_each
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4])
      assert_equal([4, 3, 2, 1], impl.reverse)
      ary = []
      impl.reverse_each { |el| ary << el }
      assert_equal([4, 3, 2, 1], ary)

      impl = klass.new([])
      assert_equal([], impl.reverse)
      impl.reverse_each { |el| assert_fail }
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise(NotImplementedError) do
        impl.reverse_each { |el| } # Nothing to do in this block.
      end
      assert_raise(NotImplementedError) { impl.reverse_each.next }
    end
  end

  def test_rindex
    FULL_IMPLS.each do |klass|
      msg = "Failed in #{klass.name}"

      impl = klass.new([1, 0, 0, 1, 0])
      assert_equal(3, impl.rindex(1), msg)

      impl = klass.new([1, 0, 0, 0, 0])
      assert_equal(0, impl.rindex(1), msg)

      impl = klass.new([0, 0, 0, 0, 0])
      assert_equal(nil, impl.rindex(1), msg)

      impl = klass.new([3, 0, 2, 0, 0])
      rindex = impl.rindex do |el|
        el > 1
      end
      assert_equal(2, rindex, msg)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise(NotImplementedError) { impl.rindex }
      assert_raise(NotImplementedError) do
        impl.rindex { |el| } # Nothing to do in this block.
      end
    end
  end

  def test_rotate
    FULL_IMPLS.each do |klass|
      ary = ["a" ,"b", "c", "d"]
      impl = klass.new(ary)
      assert_equal(ary.rotate, impl.rotate)
      (-9..9).each do |i|
        assert_equal(ary.rotate(i), impl.rotate(i))
      end
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new(["a" ,"b", "c", "d"])
      assert_raise(NotImplementedError) { impl.rotate }
      (-9..9).each do |i|
        assert_raise(NotImplementedError) { impl.rotate(i) }
      end
    end
  end

  def test_sample
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      (0..4).each do |i|
        sample = impl.sample(i)
        assert_equal(i > impl.size ? impl.size : i, sample.size,
                     "Failed #{klass.name}#sample(#{i})")
        read = []
        sample.each do |el|
          assert(impl.include?(el))
          assert(!read.include?(el))
          read << el
        end

        if i > 0
          # res will be Integer if sample always returns a same array
          # if not, res will be false.
          res = 10000.times do
            if sample != impl.sample(i)
              break false
            end
          end
          assert(!res)
        end
      end
      sample = impl.sample
      assert(impl.include?(sample))

      impl = klass.new([])
      assert_equal(nil, impl.sample)
      assert_equal([], impl.sample(1))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise(NotImplementedError) { impl.sample(0) }
      assert_raise(NotImplementedError) { impl.sample }
    end
  end

  def test_shuffle
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4, 5])
      shuffle = impl.shuffle
      assert_equal(impl, shuffle.sort)

      # res will be Integer if sample always returns a same array
      # if not, res will be false.
      res = 10000.times do
        break false if shuffle != impl.shuffle
      end
      assert(!res)

      impl = klass.new([])
      assert_equal(impl, impl.shuffle)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4, 5])
      assert_raise(NotImplementedError) { impl.shuffle }
    end
  end

  def test_slice_position
    FULL_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      assert_nil(impl.slice(-11))
      assert_equal(0, impl.slice(-10))
      assert_equal(9, impl.slice(-1))
      assert_equal(0, impl.slice(0))
      assert_equal(9, impl.slice(9))
      assert_nil(impl.slice(10))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      [-11, -10, -1].each do |pos|
        assert_raise NotImplementedError do
          impl.slice(pos)
        end
      end

      assert_equal(0, impl.slice(0))
      assert_equal(9, impl.slice(9))

      assert_raise ErrorForTest do
        impl.slice(10)
      end
    end
  end

  def test_slice_range
    FULL_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      msg = "Error in #{klass.name}"

      assert_equal(nil, impl.slice(-12..-11), msg)
      assert_equal(nil, impl.slice(-14..-10), msg)
      assert_equal([0, 1, 2], impl.slice(-10..-8), msg)
      assert_equal([8, 9], impl.slice(-2..-1), msg)
      assert_equal([1, 2, 3], impl.slice(-9..3), msg)
      assert_equal([0, 1], impl.slice(0..1), msg)
      assert_equal([8, 9], impl.slice(8..9), msg)
      assert_equal([8, 9], impl.slice(8..100), msg)
      assert_equal([], impl.slice(10..15), msg)
      assert_equal(nil, impl.slice(11..15), msg)
      assert_equal([], impl.slice(-1..-2), msg)
      assert_equal([], impl.slice(3..0), msg)
      assert_equal([], impl.slice(-1..1), msg)
      assert_equal(nil, impl.slice(15..14), msg)
      assert_equal(nil, impl.slice(-11..-20), msg)
      assert_equal(nil, impl.slice(15..5), msg)
      assert_equal([], impl.slice(-10..-20), msg)
      assert_equal([], impl.slice(1..-20), msg)

      assert_equal(nil, impl.slice(-12...-10), msg)
      assert_equal(nil, impl.slice(-14...-9), msg)
      assert_equal([0, 1, 2], impl.slice(-10...-7), msg)
      assert_equal([], impl.slice(-2...0), msg)
      assert_equal([1, 2, 3], impl.slice(-9...4), msg)
      assert_equal([0, 1], impl.slice(0...2), msg)
      assert_equal([8, 9], impl.slice(8...10), msg)
      assert_equal([8, 9], impl.slice(8...100), msg)
      assert_equal([], impl.slice(10...15), msg)
      assert_equal(nil, impl.slice(11...15), msg)
      assert_equal([], impl.slice(-1...-1), msg)
      assert_equal([], impl.slice(0...0), msg)
      assert_equal([3, 4, 5, 6, 7, 8], impl.slice(3...-1), msg)
      assert_equal([], impl.slice(-1...2), msg)
      assert_equal(nil, impl.slice(16...15), msg)
      assert_equal(nil, impl.slice(-11...-20), msg)
      assert_equal(nil, impl.slice(15...5), msg)
      assert_equal([], impl.slice(-10...-20), msg)
      assert_equal([], impl.slice(1...-20), msg)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new((0...10).to_a)
      [-12..-11, -14..-10, -10..-8, -2..-1, -1..1].each do |range|
        assert_raise NotImplementedError do
          impl.slice(range)
        end
      end

      assert_equal([0, 1], impl.slice(0..1))
      assert_equal([8, 9], impl.slice(8..9))
      assert_equal([], impl.slice(15..10))
      assert_equal([], impl.slice(-1..-2))

      [8..11, 10..15].each do |range|
        assert_raise ErrorForTest do
          impl.slice(range)
        end
      end
    end
  end

  def test_to_a_and_to_ary
    FULL_IMPLS.each do |klass|
      ary = [1, 2, 3, 4, 5]
      impl = klass.new(ary)
      assert(ary.eql?(impl.to_a))
      assert(ary.eql?(impl.to_ary))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise(NotImplementedError) { impl.to_a }
      assert_raise(NotImplementedError) { impl.to_ary }
    end
  end

  def test_transpose
    FULL_IMPLS.each do |klass|
      impl = klass.new([[1, 2], [3, 4], [5, 6]])
      assert_equal([[1, 3, 5], [2, 4, 6]], impl.transpose)

      impl = klass.new([])
      assert_equal([], impl.transpose)

      impl = klass.new([0])
      assert_raise(TypeError) { impl.transpose }

      impl = klass.new([[1, 2], [3, 4, 5]])
      assert_raise(IndexError) { impl.transpose }
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise(NotImplementedError) { impl.transpose }
    end
  end

  def test_uniq
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 1, 1, 2, 1])
      assert_equal([1, 2], impl.uniq)

      impl = klass.new([1, 1.0, Rational(1, 1)])
      assert_equal([1, 1.0, Rational(1, 1)], impl.uniq)
      uniq = impl.uniq { |n| n.to_i }
      assert_equal([1], uniq)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise(NotImplementedError) { impl.uniq }
    end
  end

  def test_values_at
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal([1, 3, 5], impl.values_at(0, 2, 4))
      assert_equal([nil, 1, 5, 1, 5, nil, nil],
                   impl.values_at(-6, -5, -1, 0, 4, 5, 100))
      assert_equal([2, 3], impl.values_at(1..2))
      assert_equal([4, 5, nil], impl.values_at(3..10))
      assert_equal([], impl.values_at(6..7))
      assert_equal([5, 4, 5, 1], impl.values_at(-1, 3..4, 0))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3, 4, 5])
      assert_equal([1, 3, 5], impl.values_at(0, 2, 4))
      assert_raise(NotImplementedError) { impl.values_at(-6, 0) }
      assert_raise(ErrorForTesting) { impl.values_at(0, 5) }
      assert_equal([2, 3], impl.values_at(1..2))
      assert_raise(ErrorForTesting) { impl.values_at(3..10) }
      assert_raise(ErrorForTesting) { impl.values_at(6..7) }
      assert_raise(NotImplementedError) { impl.values_at(-1, 3..4, 0) }
    end
  end

  def test_zip
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 2, 3])
      assert_equal([[1, 4, 7], [2, 5, 8], [3, 6, 9]],
                   impl.zip([4, 5, 6], [7, 8, 9]))
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise(NotImplementedError) { impl.zip([]) }
    end
  end

  def test_or
    FULL_IMPLS.each do |klass|
      impl = klass.new([1, 1, 4, 2, 3])
      assert_equal([1, 4, 2, 3, 5], impl | [4, 5, 5])
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise(NotImplementedError) { impl | [] }
    end
  end

end

