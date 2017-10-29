module YAFL
  module IL
    module Operators
      class EqualTo < YAFL::IL::Operator
        def precedence
          4
        end

        def associativity
          :left
        end

        def to_s
          "&&"
        end
      end
    end
  end
end

