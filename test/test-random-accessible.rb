require 'test/unit'
require 'random-accessible'

class Impl

  include RandomAccessible

  def initialize(ary)
    @a = ary
  end

  def [](pos)
    raise ArgumentError unless pos.is_a? Numeric
    @a.at(pos)
  end

  def []=(pos, obj)
    raise ArgumentError unless pos.is_a? Numeric
    @a[pos] = obj
  end

  def size
    @a.size
  end

end

class TestRandomAccesible < Test::Unit::TestCase

  def setup
    @origs = [[1, 2, 3], ['a', :b, 3, [0], 2], Array.new(100){|i|i}]
    @impls = @origs.map do |el|
      Impl.new el.clone
    end
    @test_num = @origs.size
  end

  def each
    @test_num.times do |i|
      yield @origs[i], @impls[i]
    end
  end

  def test_bracket_range
    each do |orig, impl|
      [0..0, 0..2, -2..-1, -2..1, 2..20, -20..-2].each do |r|
        assert_equal(orig[r], impl[r])
      end
    end
  end

  def test_each_with_block
    each do |orig, impl|
      enum = orig.each
      result = impl.each do |el|
        assert_equal(enum.next, el)
      end

      assert_equal(orig, result)
    end
  end

  def test_each_without_block
    each do |orig, impl|
      enum = impl.each
      assert_equal(orig, enum.to_a)
      
      orig[1] = 0
      impl[1] = 0
      assert_equal(orig, enum.to_a)

      orig[2] = 1
      impl[2] = 1
      assert_equal(orig, enum.to_a)

      orig[3] = -1
      impl[3] = -1
      assert_equal(orig, enum.to_a)
    end
  end

end
