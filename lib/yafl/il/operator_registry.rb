module YAFL
  module IL
    module OperatorRegistry
      class << self
        REGISTRY = {
          ADD: Operators::Add.new,
          AND: Operators::And.new,
          DIVIDE: Operators::Divide.new,
          EQUAL_TO: Operators::EqualTo.new,
          GREATER_THAN: Operators::GreaterThan.new,
          GREATER_THAN_OR_EQUAL_TO: Operators::GreaterThanOrEqualTo.new,
          INTERSECT: Operators::Intersect.new,
          LESS_THAN: Operators::LessThan.new,
          LESS_THAN_OR_EQUAL_TO: Operators::LessThanOrEqualTo.new,
          MOD: Operators::Mod.new,
          MULTIPLY: Operators::Multiply.new,
          NOT: Operators::Not.new,
          NOT_EQUAL_TO: Operators::NotEqualTo.new,
          OR: Operators::Or.new,
          POW: Operators::Pow.new,
          SUBTRACT: Operators::Subtract.new,
          UMINUS: Operators::UMinus.new,
          UNION: Operators::Union.new
        }.freeze

        def lookup(token_type)
          REGISTRY.fetch(token_type, nil)
        end
      end
    end
  end
end
