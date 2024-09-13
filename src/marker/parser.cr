module Marker
  class Parser
    @tokens : Array(Token)
    @pos : Int32

    def self.parse(tokens : Array(Token)) : Array(Block)
      new(tokens).parse
    end

    private def initialize(@tokens : Array(Token))
      @pos = 0
    end

    def parse : Array(Block)
      blocks = [] of Block

      loop do
        break unless block = parse_next_block
        blocks << block
      end

      blocks
    end

    private def parse_next_block : Block?
      case current_token.kind
      when .eof?
        nil
      when .right_angle?
        parse_block_quote
      when .list_item?
        parse_list
      else
        parse_leaf_block
      end
    end

    private def parse_block_quote : Block
      raise "blockquote not implemented"
    end

    private def parse_list : Block
      raise "list not implemented"
    end

    private def parse_leaf_block : Block?
      case current_token.kind
      when .eof?
        nil
      when .space?
        unless current_token.value.size > 3
          next_token
          return parse_leaf_block
        end

        parse_indented_code_block
      when .newline?
        next_token
        return parse_leaf_block
      when .thematic_break?
        parse_thematic_break
      else
        raise "leaf not implemented (on #{current_token.kind})"
      end
    end

    private def current_token : Token
      @tokens[@pos]
    end

    private def next_token : Token
      @tokens[@pos += 1]
    end

    private def parse_indented_code_block : Block
      values = [] of String
      last_is_space = true
      last_value_index = 0

      loop do
        case current_token.kind
        when .eof?
          break
        when .space?
          last_is_space = true
          if current_token.value.size > 4
            values << current_token.value[4..]
          end
          next_token
        when .newline?
          last_is_space = true
          values << current_token.value
          next_token
        else
          break unless last_is_space

          last_is_space = false
          values << current_token.value
          last_value_index = values.size - 1

          loop do
            case (inner = next_token).kind
            when .eof?
              break
            when .newline?
              values << inner.value
              last_value_index += 1
              break next_token
            else
              values << inner.value
              last_value_index += 1
            end
          end
        end
      end

      CodeBlock.new :indent, values[..last_value_index].join.strip '\n'
    end

    private def parse_thematic_break : Block
      token = current_token
      next_token

      case token.value
      when .includes? '*'
        kind = ThematicBreak::Kind::Asterisk
      when .includes? '-'
        kind = ThematicBreak::Kind::Dash
      else
        kind = ThematicBreak::Kind::Underscore
      end

      ThematicBreak.new kind, token.value.size
    end
  end
end
