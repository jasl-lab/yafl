module YAFL
  module IL
    module Operators
      class Pow < YAFL::IL::Operator
        def precedence
          11
        end

        def associativity
          :right
        end

        def to_s
          "^"
        end
      end
    end
  end
end

