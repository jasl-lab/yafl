# frozen_string_literal: true

module YAFL
  class Lexer
    attr_reader :column, :lineno, :tokens

    SKIP_PATTERN = /(?<before>[ \t]*)(?<new_line>(\n|\r\n)*)(?<after>[ \t]*)/

    IDENTIFIER_PATTERN = /[_a-z][_a-z0-9]*/

    REFERENCE_PATTERN = /\$(?<identifier>#{IDENTIFIER_PATTERN.source}|)/
    SELF_PATTERN = /@/

    PATH_PATTERN = /\.(?<identifier>#{IDENTIFIER_PATTERN.source}|\*)/
    FLATTEN_PATH_PATTERN = /\.\.(?<identifier>#{IDENTIFIER_PATTERN.source}|\*)/

    FILTER_PATTERN = /\?/

    NUMBER_PATTERN = /(-?\d+(?:\.\d+)?|\.\d+)(?:[eE][+-]?\d+)?\b/
    STRING_PATTERN = /(?<delim>['"])(?<str>.*?)\k<delim>/

    TRUE_PATTERN = /true/
    FALSE_PATTERN = /false/

    LEFT_PAREN_PATTERN = /\(/
    LEFT_BRACKET_PATTERN = /\[/

    RIGHT_PAREN_PATTERN = /\)/
    RIGHT_BRACKET_PATTERN = /]/

    COMMA_PATTERN = /,/
    COLON_PATTERN = /:/

    ADD_PATTERN = /\+/
    MINUS_PATTERN = /-/
    MUL_PATTERN = /\*/
    DIV_PATTERN = /\// # rubocop:disable Style/RegexpLiteral
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
          [[@lineno, @column], :reference, @scanner[:identifier]]
        when try_match(FLATTEN_PATH_PATTERN)
          [[@lineno, @column], :flatten_path, @scanner[:identifier]]
        when try_match(PATH_PATTERN)
          [[@lineno, @column], :path, @scanner[:identifier]]
        when try_match(FILTER_PATTERN) && @scanner.check(LEFT_PAREN_PATTERN)
          [[@lineno, @column], :filter]
        when try_match(LEFT_BRACKET_PATTERN)
          @state_stack.push [[@lineno, @column], :left_bracket]
          @state_stack.last
        when try_match(LEFT_PAREN_PATTERN)
          @state_stack.push [[@lineno, @column], :left_paren]
          @state_stack.last
        when try_match(RIGHT_BRACKET_PATTERN)
          last = @state_stack.pop
          unless last
            raise TokenizeError.unexpected(column: @column, lineno: @lineno, token: "]")
          end
          unless last[1] == :left_bracket
            raise TokenizeError.unbalanced(column: last[1], lineno: last[2], token: "[")
          end
          [[@lineno, @column], :right_bracket]
        when try_match(RIGHT_PAREN_PATTERN)
          last = @state_stack.pop
          unless last
            raise TokenizeError.unexpected(column: @column, lineno: @lineno, token: ")")
          end
          unless last[1] == :left_paren
            raise TokenizeError.unbalanced(column: last[1], lineno: last[2], token: "(")
          end
          [[@lineno, @column], :right_paren]
        when try_match(SELF_PATTERN)
          [[@lineno, @column], :self]
        when try_match(NUMBER_PATTERN)
          [[@lineno, @column], :number, BigDecimal.new(@last_captured)]
        when try_match(STRING_PATTERN)
          [[@lineno, @column], :string, @scanner[:str]]
        when try_match(TRUE_PATTERN)
          [[@lineno, @column], :boolean, true]
        when try_match(FALSE_PATTERN)
          [[@lineno, @column], :boolean, false]
        when try_match(COLON_PATTERN)
          [[@lineno, @column], :colon]
        when try_match(COMMA_PATTERN)
          [[@lineno, @column], :comma]
        when try_match(ADD_PATTERN)
          [[@lineno, @column], :add]
        when try_match(MINUS_PATTERN)
          [[@lineno, @column], :minus]
        when try_match(MUL_PATTERN)
          [[@lineno, @column], :mul]
        when try_match(DIV_PATTERN)
          [[@lineno, @column], :div]
        when try_match(POW_PATTERN)
          [[@lineno, @column], :pow]
        when try_match(MOD_PATTERN)
          [[@lineno, @column], :mod]
        when try_match(EQUAL_TO_PATTERN)
          [[@lineno, @column], :equal_to]
        when try_match(NOT_EQUAL_TO_PATTERN)
          [[@lineno, @column], :not_equal_to]
        when try_match(GREATER_THAN_OR_EQUAL_TO_PATTERN)
          [[@lineno, @column], :greater_than_or_equal_to]
        when try_match(GREATER_THAN_PATTERN)
          [[@lineno, @column], :greater_than]
        when try_match(LESS_THAN_OR_EQUAL_TO_PATTERN)
          [[@lineno, @column], :less_than_or_equal_to]
        when try_match(LESS_THAN_PATTERN)
          [[@lineno, @column], :less_than]
        when try_match(AND_PATTERN)
          [[@lineno, @column], :and]
        when try_match(OR_PATTERN)
          [[@lineno, @column], :or]
        when try_match(NOT_PATTERN)
          [[@lineno, @column], :not]
        when try_match(INTERSECT_PATTERN)
          [[@lineno, @column], :intersect]
        when try_match(UNION_PATTERN)
          [[@lineno, @column], :union]
        when try_match(IDENTIFIER_PATTERN) && @scanner.check(LEFT_PAREN_PATTERN)
          [[@lineno, @column], :function, @last_captured]
        else
          raise TokenizeError.unexpected(column: @column, lineno: @lineno, token: @scanner.peek(7))
        end

      @column += @last_captured.length
      @tokens << token

      token
    end

    def lex
      next_token until @scanner.eos?
      tokens
    end

    private

    def try_match(pattern)
      @last_captured = @scanner.scan(pattern)
    end
  end
end
