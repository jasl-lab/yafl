module YAFL
  module IL
    class Value < YAFL::IL::Node
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def to_s
        value.to_s
      end
    end
  end
end

