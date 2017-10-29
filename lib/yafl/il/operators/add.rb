module YAFL
  module IL
    module Operators
      class Add < YAFL::IL::Operator
        def precedence
          8
        end

        def associativity
          :left
        end

        def to_s
          "+"
        end
      end
    end
  end
end
