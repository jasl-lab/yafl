module YAFL
  module IL
    class Reference < YAFL::IL::LazyValue
      attr_reader :identifier

      def initialize(identifier, sequence = [])
        @identifier = identifier
        super(sequence)
      end

      def to_s
        identifier.to_s
      end
    end
  end
end

