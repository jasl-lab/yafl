module YAFL
  module IL
    class Function < YAFL::IL::Node
      attr_reader :name, :args

      def initialize(name, args = [])
        @name = name
        @args = args
      end

      def to_s
        name
      end
    end
  end
end

