# frozen_string_literal: true

require "minitest/autorun"
require "yafl"

class LexerTest < Minitest::Test
  SAMPLES = {
    "" => [],
    "1+1" => [[:number, 1], [:add], [:number, 1]],
    "-5" => [[:number, -5]],
    "(-5)" => [[:left_paren], [:number, -5], [:right_paren]],
    "if(-5 > $a, -77, -88) + 99" => [
      [:function, "if"], [:left_paren], [:number, -5], [:greater_than], [:reference, "a"],
      [:comma], [:number, -77], [:comma], [:number, -88], [:right_paren], [:add], [:number, 99]
    ],
    "1     / \n1     - $a" => [[:number, 1], [:div], [:number, 1], [:minus], [:reference, "a"]],
    "10 ^-2" => [[:number, 10], [:pow], [:number, -2]],
    "1.5* 3.7" => [[:number, 1.5], [:mul], [:number, 3.7]],
    '"giraffe" == "giraffe"' => [[:string, "giraffe"], [:equal_to], [:string, "giraffe"]],
    "-2--3" => [[:number, -2], [:minus], [:number, -3]],
    "$octopi <= 7500 && $sharks > 1500" => [
      [:reference, "octopi"], [:less_than_or_equal_to], [:number, 7500], [:and],
      [:reference, "sharks"], [:greater_than], [:number, 1500]
    ],
    "$..book[0:1:1]" => [
      [:reference, ""], [:flatten_path, "book"], [:left_bracket],
      [:number, 0], [:colon], [:number, 1], [:colon], [:number, 1],
      [:right_bracket]
    ],
    "$..book[?(@['price'] == 13 || @['price'] == 23)] + 1" => [
      [:reference, ""], [:flatten_path, "book"], [:left_bracket],
      [:filter], [:left_paren], [:self], [:left_bracket], [:string, "price"], [:right_bracket],
      [:equal_to], [:number, 13], [:or], [:self], [:left_bracket], [:string, "price"], [:right_bracket],
      [:equal_to], [:number, 23], [:right_paren], [:right_bracket], [:add], [:number, 1]
    ]
  }.freeze

  def test_lexer
    SAMPLES.each do |input, expect|
      # puts input
      lexer = YAFL::Lexer.new(input)
      tokens = lexer.lex.map { |t| t[1..-1] }

      assert_equal expect, tokens
    end
  end
end
