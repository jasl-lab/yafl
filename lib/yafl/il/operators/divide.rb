module YAFL
  module IL
    module Operators
      class Divide < YAFL::IL::Operator
        def precedence
          9
        end

        def associativity
          :left
        end

        def to_s
          "/"
        end
      end
    end
  end
end

