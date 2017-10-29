module YAFL
  module IL
    module Operators
      class LessThan < YAFL::IL::Operator
        def precedence
          5
        end

        def associativity
          :left
        end

        def to_s
          "<"
        end
      end
    end
  end
end

