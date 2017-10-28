module YAFL
  class Token
    attr_reader :type, :value, :lineno, :column

    def initialize(type, value, lineno, column)
      @type = type
      @value = value
      @lineno = lineno
      @column = column
    end
  end
end
