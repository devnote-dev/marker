require "spec"
require "../src/marker"

alias Kind = Marker::Token::Kind
alias Lexer = Marker::Lexer
alias Parser = Marker::Parser

def parse(input : String) : Array(Marker::Node)
  tokens = Lexer.new(input).run
  tree = Parser.parse tokens

  tree.nodes
end
