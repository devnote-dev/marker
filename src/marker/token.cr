module Marker
  class Location
    @value : StaticArray(Int32, 4)

    def self.[](line : Int32, column : Int32)
      new StaticArray[linel, column, line, column]
    end

    def initialize(@value : StaticArray(Int32, 4))
    end

    def start : {Int32, Int32}
      {@value[0], @value[1]}
    end

    def end : {Int32, Int32}
      {@value[2], @value[3]}
    end

    def start_at(line : Int32, column : Int32) : self
      @value[0] = line
      @value[1] = column

      self
    end

    def end_at(line : Int32, column : Int32) : self
      @value[2] = line
      @value[3] = column

      self
    end

    def &(other : Location) : Location
      Location[@value[0], @value[1]].end_at(*other.end)
    end
  end

  struct Token
    enum Kind
      EOF
      Space
      Newline
      Escape

      # Leaf block tokens

      ThematicBreak     # (?<!\s{4})(-|_|\*)(?:\1|\s){2,}$
      ATXHeading        # (?<!\s{4})(#{1,6}(?<!#{7}))\s+.+$
      SetextHeading     # (?<!\s{4})===+$
      IndentedCodeBlock # \s{4,}.*$
      FencedCodeBlock   # (?<!\s{4})(`|~)\1{2,}.*$
      HTMLBlock         # </> <!-- -->

      # Container block tokens

      BlockQuote      # >
      BulletListItem  # - or + or *
      OrderedListItem # 0-9. or 0-9)

      # Inline tokens

      Backtick     # `
      Asterisk     # *
      Underscore   # _
      LeftBracket  # [
      RightBracket # ]
      LeftParen    # (
      RightParen   # )
      LeftAngle    # <
      RightAngle   # >
      Quote        # "" or ''
      Colon        # :
      Bang         # !
      Text
    end

    getter kind : Kind
    getter loc : Location
    @value : String?

    def initialize(@kind : Kind, @loc : Location, @value : String? = nil)
    end

    def value : String
      @value.as(String)
    end
  end
end
