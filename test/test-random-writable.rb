class TestRandomWritable

  def test_lshift
    FULL_IMPLS.each do |klass|
      impl1 = klass.new([1, 2])
      impl1 << 3 << 4 << 5
      assert_equal([1, 2, 3 ,4 ,5], impl1)
    end
    NOSIZE_IMPLS.each do |klass|
      impl = klass.new([])
      assert_raise NotImplementedError do
        impl << 0
      end
    end
  end

end
