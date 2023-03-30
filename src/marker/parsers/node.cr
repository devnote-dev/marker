class Marker::Parser::CommonMark
  class Node
    enum Type
      Heading
      Paragraph
      Strong
      Emphasis
      CodeSpan
      CodeBlock
      HTMLBlock
      BlockQuote
      ListItem
      Link
      Image
      LineBreak
    end

    property type : Type
    property text : String
    property position : Position
    property parent : Node?
    property previous : Node?
    property next : Node?

    def initialize(@type : Type)
      @text = ""
      @position = Position.new
    end
  end

  class Position
    @pos : StaticArray(Int32, 4)

    def initialize
      @pos = StaticArray(Int32, 4).new 0
    end

    def line : {Int32, Int32}
      {@pos[0], @pos[1]}
    end

    def column : {Int32, Int32}
      {@pos[2], @pos[3]}
    end

    def set_start(line : Int32, column : Int32) : Nil
      @pos[0] = line
      @pos[2] = column
    end

    def set_stop(line : Int32, column : Int32) : Nil
      @pos[1] = line
      @pos[3] = column
    end

    def inspect(io : IO) : Nil
      io << "Position(@line=" << line
      io << " @column=" << column << ')'
    end
  end
end
