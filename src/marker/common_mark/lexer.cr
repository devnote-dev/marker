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

      case current_char
      when '\0'
        Token.new :eof
      when ' '
        consume_whitespace
      when '\r'
        if next_char == '\n'
          next_char
          Token.new :newline
        else
          consume_text
        end
      when '\n'
        next_char
        Token.new :newline
      when '\\'
        next_char
        Token.new :escape
      when '#'
        consume_heading
      when '*'
        case next_char
        when '*'
          next_char
          Token.new :strong, get_text_range
        when ' '
          next_char
          Token.new :list_item, get_text_range
        else
          Token.new :emphasis, get_text_range
        end
      when '_'
        if next_char == '_'
          next_char
          Token.new :strong, get_text_range
        else
          Token.new :emphasis, get_text_range
        end
      when '`'
        if next_char == '`' && next_char == '`'
          consume_code_block
        else
          consume_code_span
        end
      when '~'
        if next_char == '~' && next_char == '~'
          consume_code_block
        else
          consume_text
        end
      when '<'
        consume_html_or_text
      when '>'
        next_char
        Token.new :block_quote, get_text_range
      when '-', '+'
        next_char
        Token.new :list_item, get_text_range
      when .ascii_number?
        if current_char == '0'
          consume_text
        else
          consume_list_item
        end
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

    def consume_heading : Token
      while current_char == '#'
        next_char
      end

      Token.new :heading, get_text_range
    end

    def consume_code_block : Token
      delim = current_char
      while current_char == delim
        next_char
      end

      count = get_text_range.size
      loop do
        break if current_char == '\0'
        if current_char == delim
          nth = 1
          count.times do
            nth += 1 if next_char == delim
            break if nth == count
          end
        end
        next_char
      end

      Token.new :code_block, get_text_range
    end

    def consume_code_span : Token
      count = get_text_range.size
      loop do
        break if current_char == '\0'
        if current_char == '`'
          break if count == 1 || next_char == '`'
        end
        next_char
      end
      next_char

      Token.new :code_span, get_text_range
    end

    def consume_html_or_text : Token
      case next_char
      when '!'
        case next_char
        when '-'
          if next_char == '-'
            return consume_html_comment
          else
            return consume_text
          end
        when .ascii_letter?
          # this is fine
        else
          return consume_text
        end
      when '/'
        return consume_text unless next_char.ascii_letter?
      when .ascii_letter?
        # this is fine
      else
        return consume_text
      end

      loop do
        raise "unterminated HTML block" if current_char == '\0'
        break if current_char == '>'
        next_char
      end
      next_char

      Token.new :html_block, get_text_range
    end

    def consume_html_comment : Token
      loop do
        raise "unterminated HTML comment block" if current_char == '\0'
        if current_char == '-'
          if next_char == '-' && next_char == '>'
            break
          end
        end
        next_char
      end

      Token.new :html_block, get_text_range
    end

    def consume_list_item : Token
      loop do
        case current_char
        when .ascii_number?
          next_char
        when '.', ')'
          next_char
          break Token.new :list_item, get_text_range
        else
          break Token.new :text, get_text_range
        end
      end
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
