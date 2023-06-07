require "spec"
require "../src/marker"

alias CMark = Marker::CommonMark
alias Kind = CMark::Token::Kind
alias Lexer = CMark::Lexer
alias Parser = CMark::Parser

def parse(input : String) : Array(CMark::Node)
  tokens = Lexer.new(input).run
  tree = Parser.new(tokens).parse

  tree.nodes
end
