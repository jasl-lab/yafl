module YAFL
  module IL
    module Operators
      class GreaterThan < YAFL::IL::Operator
        def precedence
          5
        end

        def associativity
          :left
        end

        def to_s
          ">"
        end
      end
    end
  end
end

