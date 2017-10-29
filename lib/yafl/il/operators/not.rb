module YAFL
  module IL
    module Operators
      class Not < YAFL::IL::Operator
        def precedence
          10
        end

        def associativity
          :right
        end

        def to_s
          "!"
        end
      end
    end
  end
end

