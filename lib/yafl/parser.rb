module YAFL
  class Parser
    attr_reader :parsed_sequence

    def initialize(tokens, debug_mode: false)
      @tokens = tokens

      @parsed_sequence = []
      @op_stack = []

      @debug_mode = debug_mode
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def parse
      debug "Term\tAction\tOutput\tStack"
      until @tokens.empty?
        term = @tokens.shift

        if op = IL::OperatorRegistry.lookup(term.type)
          lookahead_op = @op_stack.last
          if lookahead_op.is_a?(IL::Operator) && op < lookahead_op
            @parsed_sequence << @op_stack.pop
            debug "#{term.value}\t#{op}\t#{@parsed_sequence.map(&:to_s)}\t#{@op_stack.map(&:to_s)}\t#{lookahead_op} has higher precedence than #{op}"
          end
          @op_stack << op
          debug "#{op}\tPUSH OP\t#{@parsed_sequence.map(&:to_s)}\t#{@op_stack.map(&:to_s)}"

          next
        end

        case term.type
        when :OPEN_PAREN
          @op_stack << Placeholder.open_paren
          debug "#{term.value}\tOPEN_P\t#{@parsed_sequence.map(&:to_s)}\t#{@op_stack.map(&:to_s)}"
        when :CLOSE_PAREN
          until @op_stack.last == Placeholder.open_paren
            @parsed_sequence << @op_stack.pop
            debug "#{term.value}\t#{@parsed_sequence.last}\t#{@parsed_sequence.map(&:to_s)}\t#{@op_stack.map(&:to_s)}\tunwinding parenthesis"
          end
          @op_stack.pop
          debug "#{term.value}\tCLOSE_P\t#{@parsed_sequence.map(&:to_s)}\t#{@op_stack.map(&:to_s)}"
        else
          @parsed_sequence << IL::Value.new(term.value)
          debug "#{term.value}\tPUSH V\t#{@parsed_sequence.map(&:to_s)}\t#{@parsed_sequence.map(&:to_s)}"
        end
      end

      @parsed_sequence << @op_stack.pop until @op_stack.empty?

      @parsed_sequence
    end

    def debug(msg)
      puts msg if @debug_mode
    end

    class Placeholder
      attr_reader :type, :value

      def initialize(type, value)
        @type = type
        @value = value
      end

      def to_s
        value.to_s
      end

      def ==(other)
        super && type == other.type
      end

      class << self
        def open_paren
          @open_paren ||= new(:OPEN_PAREN, "(")
        end
      end
    end
    private_constant :Placeholder
  end
end

