module YAFL
  module IL
    module Operators
      class Union < YAFL::IL::Operator
        def precedence
          6
        end

        def associativity
          :left
        end

        def to_s
          "|"
        end
      end
    end
  end
end

