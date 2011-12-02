# Author:: Natsuki Kawai (natsuki.kawai@gmail.com)
# Copyright:: Copyright 2011 Natsuki Kawai
# License:: 2-clause BSDL or Ruby's


module RandomAccessible

  # RandomAccessible::CommonTraits mixin provides methods
  # commonly used for read and write access.
  module CommonTraits

    # Same as Array's.
    # This method evaluates no element of the class.
    # This method raises NotImplementedError
    # if the class provides neither size nor length method.
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

    # Same as Array's.
    # This method evaluates no element of the class.
    # This method raises NotImplementedError
    # if the class provides neither size nor length method.
    def empty?
      if has_size?
        size <= 0
      else
        false
      end
    end

    # Returns true if the object implements size or length method.
    def has_size?
      return method(:size).owner != CommonTraits ||
             method(:length).owner != CommonTraits
    end
    private :has_size?

    # This method is a size-provider (see README).
    # Overriding method returns the number of the elements.
    def size
      if method(:length).owner == CommonTraits
        raise NotImplementedError,
              "#{self.class.to_s} overrides neither length method nor size method."
      end
      return length
    end

    # This method is a size-provider (see README).
    # Overriding method returns the number of the elements.
    def length
      if method(:size).owner == CommonTraits
        raise NotImplementedError,
              "#{self.class.to_s} overrides neither length method nor size method."
      end
      return size
    end

  end

end
