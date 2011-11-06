module RandomAccessable

  module CommonTraits

    def each_index(&block)
      if block.nil?
        Enumerator.new do |y|
          size.times do |i|
            y << i
          end
        end
      else
        size.times do |i|
          block.call(i)
        end
      end
    end

    def empty?
      if has_size?
        size <= 0
      else
        false
      end
    end

    def has_size?
      return method(:size).owner != CommonTraits ||
             method(:length).owner != CommonTraits
    end
    private :has_size?

    def size
      if method(:length).owner == CommonTraits
        raise NotImplementedError,
              "#{self.class.to_s} has neither length method nor size method."
      end
      return length
    end

    def length
      if method(:size).owner == CommonTraits
        raise NotImplementedError,
              "#{self.class.to_s} has neither length method nor size method."
      end
      return size
    end

  end

end
