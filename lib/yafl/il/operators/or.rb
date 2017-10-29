module YAFL
  module IL
    module Operators
      class Or < YAFL::IL::Operator
        def precedence
          2
        end

        def associativity
          :left
        end

        def to_s
          "||"
        end
      end
    end
  end
end

