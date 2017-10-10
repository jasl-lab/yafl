# frozen_string_literal: true

require "strscan"

module YAFL
  class Tokenizer
    TOKENS = {
      reference: /\$(?:[\w]*)/,
      path_all: /\.\.\*/, path_recursive_descent: /\.\./, path_wildcard: /\.(?:\w+)/, filter: /\?/,
      left_parenthesis: /\(/, right_parenthesis: /\)/,
      left_bracket: /\[/, right_bracket: /]/,
      left_brace: /{/, right_brace: /}/,
      equal_to: /==/, not_equal_to: /!=/,
      greater_than: />/, greater_than_or_equal_to: />=/,
      less_than: /</, less_than_or_equal_to: /<=/,
      not: /!/, and: /&&/, or: /\|\|/,
      intersect: /&/, union: /\|/,
      add: /\+/, minus: /-/, multiply: /\*/, divide: /\//, pow: /\^/,
      colon: /:/, comma: /,/, self: /@/,
      true_value: /true/, false_value: /false/, null_value: /null/,
      single_quote_string: /'(?:[^']*)'/, double_quote_string: /"(?:[^"]*)"/,
      number: /((?:\d+(\.\d+)?|\.\d+)(?:[eE][+-]?\d+)?)\b/
    }.freeze

    SPACE_OR_NEW_LINE = /[\r\n\s]+/

    def initialize(exp)
      @ss = StringScanner.new exp
    end

    def next_token
      return if @ss.eos?
      @ss.skip(SPACE_OR_NEW_LINE)

      pos = @ss.pos

      TOKENS.each do |token_type, pattern|
        text = @ss.scan(pattern)
        next unless text
        return [token_type, text, pos]
      end

      # TODO: raise TokenizeError
      x = @ss.getch
      [x, x, @ss.pos]
    end

    def eos?
      @ss.eos?
    end

    def self.tokenize!(exp)
      tokenizer = new exp
      tokens = []
      tokens << tokenizer.next_token until tokenizer.eos?

      validate_balanced!(tokens)

      tokens
    end

    def self.validate_balanced!(tokens)
      s = []

      tokens.each do |t|
        case t[0]
        when :left_parenthesis
          s.push :left_parenthesis
        when :right_parenthesis
          raise TokenizeError unless s.pop == :left_parenthesis
        when :left_bracket
          s.push :left_bracket
        when :right_bracket
          raise TokenizeError unless s.pop == :left_bracket
        when :left_brace
          s.push :left_brace
        when :right_brace
          raise TokenizeError unless s.pop == :left_brace
        end
      end

      raise TokenizeError unless s.empty?
    end
  end
end
