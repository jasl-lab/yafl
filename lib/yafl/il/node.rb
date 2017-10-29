module YAFL
  module IL
    class Node
      def to_s
        raise NotImplementedError
      end

      def ==(other)
        self.class == other.class
      end
    end
  end
end
