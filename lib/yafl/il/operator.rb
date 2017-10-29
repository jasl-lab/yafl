module YAFL
  module IL
    class Operator < YAFL::IL::Node
      def precedence
        raise NotImplementedError
      end

      def associativity
        raise NotImplementedError
      end

      def left_associative?
        associativity == :left
      end

      def <(other)
        if left_associative?
          precedence <= other.precedence
        else
          precedence < other.precedence
        end
      end
    end
  end
end
