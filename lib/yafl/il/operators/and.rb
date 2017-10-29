module YAFL
  module IL
    module Operators
      class And < YAFL::IL::Operator
        def precedence
          3
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

