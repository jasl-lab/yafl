# frozen_string_literal: true

require "minitest/autorun"
require "yafl"

class TokenizerTest < Minitest::Test
  SAMPLES = {
    "" => [],
    "1+1" => [[:NUMBER, 1], [:ADD], [:NUMBER, 1]],
    "-5" => [[:NUMBER, -5]],
    "(-5)" => [[:OPEN_PAREN], [:NUMBER, -5], [:CLOSE_PAREN]],
    "if(-5 > $a, -77, -88) + 99" => [
      [:FUNCTION, "if"], [:OPEN_PAREN], [:NUMBER, -5], [:GREATER_THAN], [:REFERENCE, "a"],
      [:COMMA], [:NUMBER, -77], [:COMMA], [:NUMBER, -88], [:CLOSE_PAREN], [:ADD], [:NUMBER, 99]
    ],
    "1     / \n1     - $a" => [[:NUMBER, 1], [:DIVIDE], [:NUMBER, 1], [:SUBTRACT], [:REFERENCE, "a"]],
    "10 ^-2" => [[:NUMBER, 10], [:POW], [:NUMBER, -2]],
    "1.5* 3.7" => [[:NUMBER, 1.5], [:MULTIPLY], [:NUMBER, 3.7]],
    '"giraffe" == "giraffe"' => [[:STRING, "giraffe"], [:EQUAL_TO], [:STRING, "giraffe"]],
    "-2--3" => [[:NUMBER, -2], [:SUBTRACT], [:NUMBER, -3]],
    "$octopi <= 7500 && $sharks > 1500" => [
      [:REFERENCE, "octopi"], [:LESS_THAN_OR_EQUAL_TO], [:NUMBER, 7500], [:AND],
      [:REFERENCE, "sharks"], [:GREATER_THAN], [:NUMBER, 1500]
    ],
    "$.book[0:1:1]" => [
      [:REFERENCE, ""], [:PATH, "book"], [:OPEN_BRACKET],
      [:NUMBER, 0], [:COLON], [:NUMBER, 1], [:COLON], [:NUMBER, 1],
      [:CLOSE_BRACKET]
    ],
    "$.book[?(@['price'] == 13 || @['price'] == 23)] + 1" => [
      [:REFERENCE, ""], [:PATH, "book"], [:OPEN_BRACKET],
      [:FILTER], [:OPEN_PAREN], [:SELF], [:OPEN_BRACKET], [:STRING, "price"], [:CLOSE_BRACKET],
      [:EQUAL_TO], [:NUMBER, 13], [:OR], [:SELF], [:OPEN_BRACKET], [:STRING, "price"], [:CLOSE_BRACKET],
      [:EQUAL_TO], [:NUMBER, 23], [:CLOSE_PAREN], [:CLOSE_BRACKET], [:ADD], [:NUMBER, 1]
    ]
  }.freeze

  def test_lexer
    SAMPLES.each do |input, expect|
      # puts input
      lexer = YAFL::Tokenizer.new(input)
      tokens = lexer.tokenize.map { |t| [t[0], t[1][0]].compact }

      assert_equal expect, tokens
    end
  end
end
