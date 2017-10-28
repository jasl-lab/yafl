# frozen_string_literal: true

module YAFL
  class YAFLError < StandardError
  end

  class TokenizeError < YAFLError
    attr_reader :type, :column, :lineno, :token

    def initialize(type, token, lineno, column, message)
      @type = type
      @column = column
      @lineno = lineno
      @token = token

      super(message)
    end

    class << self
      def unexpected(token, lineno, column)
        new(
          :unexpected, token, lineno, column,
          "unexpected \"#{token.length > 6 ? "#{token[0..5]}..." : token}\" at lineno #{lineno} column: #{column}"
        )
      end

      def unbalanced(token, lineno, column)
        new(
          :unbalanced, token, lineno, column,
          "unbalanced \"#{token}\" at lineno #{lineno} column: #{column}"
        )
      end
    end
  end
end
