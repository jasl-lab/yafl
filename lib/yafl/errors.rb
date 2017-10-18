# frozen_string_literal: true

module YAFL
  class YAFLError < StandardError
  end

  class TokenizeError < YAFLError
    attr_reader :type, :column, :lineno, :token

    def initialize(type:, column:, lineno:, token:, message:)
      @type = type
      @column = column
      @lineno = lineno
      @token = token

      super(message)
    end

    class << self
      def unexpected(column:, lineno:, token:)
        new(
          type: :unexpected, column: column, lineno: lineno, token: token,
          message: "unexpected \"#{token.length > 6 ? "#{token[0..5]}..." : token}\" at lineno #{lineno} column: #{column}"
        )
      end

      def unbalanced(column:, lineno:, token:)
        new(
          type: :unbalanced, column: column, lineno: lineno, token: token,
          message: "unbalanced \"#{token}\" at lineno #{lineno} column: #{column}"
        )
      end
    end
  end
end
