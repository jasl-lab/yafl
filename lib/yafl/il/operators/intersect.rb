module YAFL
  module IL
    module Operators
      class Intersect < YAFL::IL::Operator
        def precedence
          7
        end

        def associativity
          :left
        end

        def to_s
          "&"
        end
      end
    end
  end
end

