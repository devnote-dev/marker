module Marker::CommonMark
  class Lexer
    TERMINATORS = {'\0', '\r', '\n'}

    @reader : Char::Reader
    @pool : StringPool
    @start : Int32

    def initialize(input : String)
      @reader = Char::Reader.new input
      @pool = StringPool.new
      @start = 0
    end

    def run : Array(Token)
      tokens = [] of Token

      loop do
        token = next_token
        tokens << token
        break if token.kind.eof?
      end

      tokens
    end

    def next_token : Token
      @start = @reader.pos

      case char = current_char
      when '\0'
        Token.new :eof
      when ' '
        consume_whitespace
      when '\r', '\n'
        if char == '\r'
          raise "expected '\\n' after '\\r'" unless next_char == '\n'
        end
        next_char

        Token.new :newline
      else
        consume_text
      end
    end

    def consume_whitespace : Token
      while current_char == ' '
        next_char
      end

      Token.new :space, get_text_range
    end

    def consume_text : Token
      loop do
        break if current_char.in? TERMINATORS
        break if current_char.in?('\\', '#', '*', '_', '`', '~', '<', '>', '-', '+')
        next_char
      end

      Token.new :text, get_text_range
    end

    protected def current_char : Char
      @reader.current_char
    end

    protected def next_char : Char
      @reader.next_char
    end

    protected def get_text_range : String
      stop = @reader.pos - @start
      slice = Slice.new(@reader.string.to_unsafe + @start, stop)

      @pool.get slice
    end
  end
end
