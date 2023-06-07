module Marker::CommonMark
  class Parser
    @tokens : Array(Token)
    @pos : Int32

    def initialize(@tokens : Array(Token))
      @pos = 0
    end

    def parse : SyntaxTree
      nodes = [] of Node

      loop do
        node = parse_node current_token
        break if node.nil?
        nodes << node
      end

      SyntaxTree.new nodes
    end

    def parse_node(token : Token) : Node?
      case token.kind
      when .heading?
        if next_token.kind.space?
          if token.value.size > 5
            parse_paragraph previous_token
          else
            parse_heading token
          end
        else
          parse_paragraph previous_token
        end
      when .text?
        parse_paragraph token
      when .strong?
        if next_token.kind.space?
          parse_strong
        else
          parse_paragraph previous_token
        end
      when .emphasis?
        if next_token.kind.space?
          parse_emphasis
        else
          parse_paragraph previous_token
        end
      when .newline?
        parse_node next_token
      end
    end

    def parse_heading(token : Token) : Node
      level = token.value.size
      token = next_token
      value = [] of Node

      loop do
        case token.kind
        when .eof?, .newline?
          break
        when .heading?
          next
        when .strong?
          value << parse_strong
        when .emphasis?
          value << parse_emphasis
        else
          value << Text.new token.value
        end
        token = next_token
      end

      Heading.new level, value
    end

    def parse_paragraph(token : Token) : Node
      value = [] of Node

      loop do
        case token.kind
        when .eof?, .newline?
          break
        when .strong?
          value << parse_strong
        when .emphasis?
          value << parse_emphasis
        else
          value << Text.new token.value
        end
        token = next_token
      end

      Paragraph.new value
    end

    def parse_strong : Node
      value = [] of Node

      loop do
        token = next_token
        case token.kind
        when .eof?, .newline?
          return Paragraph.new value
        when .strong?
          break
        when .emphasis?
          value << parse_emphasis
        else
          value << Text.new token.value
        end
      end

      Strong.new value
    end

    def parse_emphasis : Node
      value = [] of Node

      loop do
        token = next_token
        case token.kind
        when .eof?, .newline?
          return Paragraph.new value
        when .strong?
          value << parse_strong
        when .emphasis?
          break
        else
          value << Text.new token.value
        end
      end

      Emphasis.new value
    end

    protected def current_token : Token
      @tokens[@pos]
    end

    protected def peek_token : Token
      @tokens[@pos + 1]
    end

    protected def next_token : Token
      @tokens[@pos += 1]
    end

    protected def previous_token : Token
      @tokens[@pos -= 1]
    end
  end
end
