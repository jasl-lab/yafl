module YAFL
  module IL
    module Operators
      class Mod < YAFL::IL::Operator
        def precedence
          9
        end

        def associativity
          :left
        end

        def to_s
          "%"
        end
      end
    end
  end
end

