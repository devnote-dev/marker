require "spec"
require "../src/marker"

alias Kind = Marker::Token::Kind

def lex(source : String) : Array(Marker::Token)
  Marker::Lexer.lex source
end

def assert_tokens(source : String, *kinds : Kind) : Nil
  lex(source).each_with_index do |token, index|
    token.kind.should eq kinds[index]
  end
end
