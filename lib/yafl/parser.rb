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
      IL::LazyValue.new parse_infix_tokens @tokens
    end

    # rubocop:disable Metrics/BlockNesting
    def parse_infix_tokens(tokens)
      sequence = []
      op_stack = []

      debug tokens.map(&:value).join(" ")
      debug "Term\tAction\tOutput\tStack"
      until tokens.empty?
        term = tokens.shift

        if op = IL::OperatorRegistry.lookup(term.type)
          lookahead_op = op_stack.last
          if lookahead_op.is_a?(IL::Operator) && op < lookahead_op
            sequence << op_stack.pop
            debug "#{term.value}\t#{op}\t#{sequence.map(&:to_s)}\t#{op_stack.map(&:to_s)}\t#{lookahead_op} has higher precedence than #{op}"
          end
          op_stack << op
          debug "#{op}\tPUSH OP\t#{sequence.map(&:to_s)}\t#{op_stack.map(&:to_s)}"

          next
        end

        case term.type
        when :OPEN_PAREN
          op_stack << Placeholder.open_paren
          debug "#{term.value}\tOPEN_P\t#{sequence.map(&:to_s)}\t#{op_stack.map(&:to_s)}"
        when :CLOSE_PAREN
          until op_stack.last == Placeholder.open_paren
            sequence << op_stack.pop
            debug "#{term.value}\t#{sequence.last}\t#{sequence.map(&:to_s)}\t#{op_stack.map(&:to_s)}\tunwinding parenthesis"
          end
          op_stack.pop
          debug "#{term.value}\tCLOSE_P\t#{sequence.map(&:to_s)}\t#{op_stack.map(&:to_s)}"
        when :FUNCTION
          func = IL::Function.new(term.value)
          term = tokens.shift
          unless term.type == :OPEN_PAREN
            raise ParseError.unexpected(term.value, term.lineno, term.column)
          end

          balance = 0
          sub_sequence = []
          until tokens.empty?
            term = tokens.shift

            case term.type
            when :OPEN_PAREN
              balance += 1
              sub_sequence << term
            when :CLOSE_PAREN
              balance -= 1
              break if balance == -1
              sub_sequence << term
            when :COMMA
              raise "unbalance" unless balance.zero?
              raise "unexpected" if tokens.first.type == :CLOSE_PAREN
              raise "unexpected" if sub_sequence.empty?

              func.args << parse_infix_tokens(sub_sequence)
              sub_sequence = []
            else
              sub_sequence << term
            end
          end
          raise "unexpected" if tokens.empty? && balance != -1
          func.args << parse_infix_tokens(sub_sequence) if sub_sequence.any?

          sequence << func
        when :REFERENCE
          ref = IL::Reference.new(term.value)
          until tokens.empty?
            term = tokens.first
            case term.type
            when :PATH
              ref.sequence.push IL::KeyPath.new(term.value)
              tokens.shift
            when :OPEN_BRACKET
              tokens.shift
              path_type =
                if tokens.first.type == :FILTER
                  tokens.shift
                  IL::FilterPath
                else
                  IL::LazyPath
                end

              balance = 0
              sub_sequence = []
              until tokens.empty?
                term = tokens.shift

                case term.type
                when :OPEN_BRACKET
                  balance += 1
                when :CLOSE_BRACKET
                  balance -= 1
                  break if balance == -1
                end
                sub_sequence << term
              end
              ref.sequence.push path_type.new(parse_infix_tokens(sub_sequence))
            else
              break
            end
          end
          sequence << ref
        else
          sequence << IL::Value.new(term.value)
          debug "#{term.value}\tPUSH V\t#{sequence.map(&:to_s)}\t#{sequence.map(&:to_s)}"
        end
      end

      sequence << op_stack.pop until op_stack.empty?

      sequence
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

