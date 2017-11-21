module YAFL
  module IL
    class FilterPath < YAFL::IL::Node
      attr_reader :sequence

      def initialize(sequence = [])
        @sequence = sequence
      end

      def to_s
        @sequence.to_s
      end
    end
  end
end

