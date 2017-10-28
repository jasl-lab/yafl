# frozen_string_literal: true

module YAFL
  class Tokenizer
    attr_reader :column, :lineno, :tokens

    SKIP_PATTERN = /(?<before>[ \t]*)(?<new_line>(\n|\r\n)*)(?<after>[ \t]*)/

    IDENTIFIER_PATTERN = /[_a-z][_a-z0-9]*/

    REFERENCE_PATTERN = /\$(?<identifier>#{IDENTIFIER_PATTERN.source}|)/
    SELF_PATTERN = /@/

    PATH_PATTERN = /\.(?<identifier>#{IDENTIFIER_PATTERN.source}|\*)/

    FILTER_PATTERN = /\?/

    NUMBER_PATTERN = /(-?\d+(?:\.\d+)?|\.\d+)(?:[eE][+-]?\d+)?\b/
    STRING_PATTERN = /(?<delim>['"])(?<str>.*?)\k<delim>/

    TRUE_PATTERN = /true/
    FALSE_PATTERN = /false/

    OPEN_PAREN_PATTERN = /\(/
    OPEN_BRACKET_PATTERN = /\[/

    CLOSE_PAREN_PATTERN = /\)/
    CLOSE_BRACKET_PATTERN = /]/

    COMMA_PATTERN = /,/
    COLON_PATTERN = /:/

    ADD_PATTERN = /\+/
    SUBTRACT_PATTERN = /-/
    MULTIPLY_PATTERN = /\*/
    DIVIDE_PATTERN = /\// # rubocop:disable Style/RegexpLiteral
    POW_PATTERN = /\^/
    MOD_PATTERN = /%/
    INTERSECT_PATTERN = /&/
    UNION_PATTERN = /\|/

    NOT_PATTERN = /!/
    AND_PATTERN = /&&/
    OR_PATTERN = /\|\|/
    EQUAL_TO_PATTERN = /==/
    NOT_EQUAL_TO_PATTERN = /!=/
    GREATER_THAN_PATTERN = />/
    GREATER_THAN_OR_EQUAL_TO_PATTERN = />=/
    LESS_THAN_PATTERN = /</
    LESS_THAN_OR_EQUAL_TO_PATTERN = /<=/

    def initialize(exp)
      @column = 0
      @lineno = 1
      @tokens = []

      @scanner = StringScanner.new exp.rstrip
      @state_stack = []
      @last_captured = ""
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def next_token
      return if @scanner.eos?

      if @scanner.scan(SKIP_PATTERN)
        @column += @scanner[:before].length

        new_lines = @scanner[:new_line].delete("\r")
        unless new_lines.empty?
          @lineno += new_lines.length
          @column = 0
        end

        @column += @scanner[:after].length
      end

      token =
        case
        when try_match(REFERENCE_PATTERN)
          Token.new :REFERENCE, @scanner[:identifier], @lineno, @column
        when try_match(PATH_PATTERN)
          Token.new :PATH, @scanner[:identifier], @lineno, @column
        when try_match(FILTER_PATTERN) && @scanner.check(OPEN_PAREN_PATTERN)
          Token.new :FILTER, nil, @lineno, @column
        when try_match(OPEN_BRACKET_PATTERN)
          @state_stack.push Token.new :OPEN_BRACKET, nil, @lineno, @column
          @state_stack.last
        when try_match(OPEN_PAREN_PATTERN)
          @state_stack.push Token.new :OPEN_PAREN, nil, @lineno, @column
          @state_stack.last
        when try_match(CLOSE_BRACKET_PATTERN)
          last = @state_stack.pop
          unless last
            raise TokenizeError.unexpected("]", @lineno, @column)
          end
          unless last.type == :OPEN_BRACKET
            raise TokenizeError.unbalanced("[", last.lineno, last.column)
          end
          Token.new :CLOSE_BRACKET, nil, @lineno, @column
        when try_match(CLOSE_PAREN_PATTERN)
          last = @state_stack.pop
          unless last
            raise TokenizeError.unexpected(")", @lineno, @column)
          end
          unless last.type == :OPEN_PAREN
            raise TokenizeError.unbalanced("(", last.lineno, last.column)
          end
          Token.new :CLOSE_PAREN, nil, @lineno, @column
        when try_match(SELF_PATTERN)
          Token.new :SELF, nil, @lineno, @column
        when try_match(NUMBER_PATTERN)
          Token.new :NUMBER, BigDecimal.new(@last_captured), @lineno, @column
        when try_match(STRING_PATTERN)
          Token.new :STRING, @scanner[:str], @lineno, @column
        when try_match(TRUE_PATTERN)
          Token.new :BOOLEAN, true, @lineno, @column
        when try_match(FALSE_PATTERN)
          Token.new :BOOLEAN, false, @lineno, @column
        when try_match(COLON_PATTERN)
          Token.new :COLON, nil, @lineno, @column
        when try_match(COMMA_PATTERN)
          Token.new :COMMA, nil, @lineno, @column
        when try_match(ADD_PATTERN)
          Token.new :ADD, nil, @lineno, @column
        when try_match(SUBTRACT_PATTERN)
          Token.new :SUBTRACT, nil, @lineno, @column
        when try_match(MULTIPLY_PATTERN)
          Token.new :MULTIPLY, nil, @lineno, @column
        when try_match(DIVIDE_PATTERN)
          Token.new :DIVIDE, nil, @lineno, @column
        when try_match(POW_PATTERN)
          Token.new :POW, nil, @lineno, @column
        when try_match(MOD_PATTERN)
          Token.new :MOD, nil, @lineno, @column
        when try_match(EQUAL_TO_PATTERN)
          Token.new :EQUAL_TO, nil, @lineno, @column
        when try_match(NOT_EQUAL_TO_PATTERN)
          Token.new :NOT_EQUAL_TO, nil, @lineno, @column
        when try_match(GREATER_THAN_OR_EQUAL_TO_PATTERN)
          Token.new :GREATER_THAN_OREQUAL_TO, nil, @lineno, @column
        when try_match(GREATER_THAN_PATTERN)
          Token.new :GREATER_THAN, nil, @lineno, @column
        when try_match(LESS_THAN_OR_EQUAL_TO_PATTERN)
          Token.new :LESS_THAN_OR_EQUAL_TO, nil, @lineno, @column
        when try_match(LESS_THAN_PATTERN)
          Token.new :LESS_THAN, nil, @lineno, @column
        when try_match(AND_PATTERN)
          Token.new :AND, nil, @lineno, @column
        when try_match(OR_PATTERN)
          Token.new :OR, nil, @lineno, @column
        when try_match(NOT_PATTERN)
          Token.new :NOT, nil, @lineno, @column
        when try_match(INTERSECT_PATTERN)
          Token.new :INTERSECT, nil, @lineno, @column
        when try_match(UNION_PATTERN)
          Token.new :UNION, nil, @lineno, @column
        when try_match(IDENTIFIER_PATTERN) && @scanner.check(OPEN_PAREN_PATTERN)
          Token.new :FUNCTION, @last_captured, @lineno, @column
        else
          raise TokenizeError.unexpected(@scanner.peek(7), @lineno, @column)
        end

      @column += @last_captured.length
      @tokens << token

      token
    end

    def tokenize
      next_token until @scanner.eos?
      tokens
    end

    private

    def try_match(pattern)
      @last_captured = @scanner.scan(pattern)
    end
  end
end
