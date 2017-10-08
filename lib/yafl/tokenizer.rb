# frozen_string_literal: true

require "strscan"

module YAFL
  class Tokenizer
    SINGLE_QUOTE_STRING = /'(?:[^']*)'/
    DOUBLE_QUOTE_STRING = /"(?:[^"]*)"/
    NUMBER = /((?:\d+(\.\d+)?|\.\d+)(?:[eE][+-]?\d+)?)\b/

    TRUE  = /true/
    FALSE = /false/
    NULL  = /null/

    ADD   = /\+/
    MIN   = /-/
    MUL   = /\*/
    DIV   = /\//
    SLICE = /:/
    COMMA = /,/

    EQUAL_TO = /==/
    NOT_EQUAL_TO = /!=/
    GREATER_THAN = />/
    GREATER_THAN_OR_EQUAL_TO = />=/
    LESS_THAN = /</
    LESS_THAN_OR_EQUAL_TO = /<=/
    NOT = /!/

    L_PAREN = /\(/
    R_PAREN = /\)/
    L_BRACKET = /\[/
    R_BRACKET = /]/

    REFERENCE = /\$(?:[\w_]*)/
    IDENTIFIER = /[\w_]+/
    SELF = /@/
    PATH_ALL = /\.\.\*[^*]+/
    PATH_RECURSIVE_DESCENT = /\.\./
    PATH_WILDCARD = /\.\*/
    PATH = /\./
    FILTER = /\?/

    SPACE_OR_NEW_LINE = /[\r\n\s]+/

    def initialize(exp)
      @ss = StringScanner.new exp
    end

    def next_token
      return if @ss.eos?
      @ss.skip(SPACE_OR_NEW_LINE)

      pos = @ss.pos
      if text = @ss.scan(REFERENCE)
        [:reference, text, pos]
      elsif text = @ss.scan(IDENTIFIER)
        [:identifier, text, pos]
      elsif text = @ss.scan(PATH_ALL)
        [:all_path, text, pos]
      elsif text = @ss.scan(PATH_RECURSIVE_DESCENT)
        [:path_recursive_descent, text, pos]
      elsif text = @ss.scan(PATH_WILDCARD)
        [:path_wild_card, text, pos]
      elsif text = @ss.scan(PATH)
        [:path, text, pos]
      elsif text = @ss.scan(L_BRACKET)
        [:l_bracket, text, pos]
      elsif text = @ss.scan(R_BRACKET)
        [:r_bracket, text, pos]
      elsif text = @ss.scan(L_PAREN)
        [:l_paren, text, pos]
      elsif text = @ss.scan(R_PAREN)
        [:r_paren, text, pos]
      elsif text = @ss.scan(FILTER)
        [:filter, text, pos]
      elsif text = @ss.scan(SELF)
        [:self, text, pos]
      elsif text = @ss.scan(SINGLE_QUOTE_STRING)
        [:string, text, pos]
      elsif text = @ss.scan(DOUBLE_QUOTE_STRING)
        [:string, text, pos]
      elsif text = @ss.scan(NUMBER)
        [:number, text, pos]
      elsif text = @ss.scan(EQUAL_TO)
        [:equal_to, text, pos]
      elsif text = @ss.scan(NOT_EQUAL_TO)
        [:not_equal_to, text, pos]
      elsif text = @ss.scan(GREATER_THAN)
        [:greater_than, text, pos]
      elsif text = @ss.scan(GREATER_THAN_OR_EQUAL_TO)
        [:greater_than_or_equal_to, text, pos]
      elsif text = @ss.scan(LESS_THAN)
        [:less_than, text, pos]
      elsif text = @ss.scan(LESS_THAN_OR_EQUAL_TO)
        [:less_than_or_equal_to, text, pos]
      elsif text = @ss.scan(NOT)
        [:not, text, pos]
      elsif text = @ss.scan(SLICE)
        [:slice, text, pos]
      elsif text = @ss.scan(COMMA)
        [:comma, text, pos]
      elsif text = @ss.scan(TRUE)
        [:true, text, pos]
      elsif text = @ss.scan(FALSE)
        [:false, text, pos]
      elsif text = @ss.scan(NULL)
        [:null, text, pos]
      elsif text = @ss.scan(ADD)
        [:add, text, pos]
      elsif text = @ss.scan(MIN)
        [:min, text, pos]
      elsif text = @ss.scan(MUL)
        [:mul, text, pos]
      elsif text = @ss.scan(DIV)
        [:div, text, @ss.pos]
      else
        x = @ss.getch
        [x, x, @ss.pos]
      end
    end

    def eos?
      @ss.eos?
    end

    def self.tokenize!(exp)
      tokenizer = new exp
      tokens = []
      tokens << tokenizer.next_token until tokenizer.eos?

      validate_balenced!(tokens)

      tokens
    end

    def self.validate_balenced!(tokens)
      s = []

      tokens.each do |t|
        case t[0]
        when :l_paren
          s.push :l_paren
        when :r_paren
          raise TokenizeError unless s.pop == :l_paren
        when :l_bracket
          s.push :l_bracket
        when :r_bracket
          raise TokenizeError unless s.pop == :l_bracket
        end
      end

      raise TokenizeError unless s.empty?
    end
  end
end
