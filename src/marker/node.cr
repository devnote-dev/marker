module Marker
  abstract class Node
  end

  class Block < Node
  end

  class Inline < Node
  end

  class BlockQuote < Block
  end

  class List < Block
  end

  class Leaf < Block
  end

  class ThematicBreak < Leaf
    enum Kind
      Asterisk
      Dash
      Underscore
    end

    property kind : Kind
    property size : Int32

    def initialize(@kind, @size)
    end
  end

  class Heading < Leaf
    enum Kind
      ATX
      Setext
    end

    property kind : Kind
    property level : Int32
    property values : Array(Inline)

    def initialize(@kind, @level, @values)
    end
  end

  class CodeBlock < Leaf
    enum Kind
      Backtick
      Indent
      Tilde
    end

    property kind : Kind
    property value : String

    def initialize(@kind, @value)
    end
  end

  # class HTMLBlock < Leaf
  # end

  class LinkReference < Leaf
    property label : String
    property destination : String
    property title : String?

    def initialize(@label, @destination, @title = nil)
    end
  end

  class Paragraph < Leaf
    property values : Array(Inline)

    def initialize(@values)
    end
  end

  class CodeSpan < Inline
    property value : String

    def initialize(@value)
    end
  end

  class Emphasis < Inline
    property value : String

    def initialize(@value)
    end
  end

  class Strong < Inline
    property value : String

    def initialize(@value)
    end
  end

  class Link < Inline
    property text : Array(Inline)
    property destination : String
    property title : String?

    def initialize(@text, @destination, @title = nil)
    end
  end

  class Image < Inline
    property description : Array(Inline)
    property destination : String
    property title : String?

    def initialize(@description, @destination, @title = nil)
    end
  end

  class AutoLink < Inline
    property url : String

    def initialize(@url)
    end
  end

  class HardBreak < Inline
  end

  class Text < Inline
    property value : String

    def initialize(@value)
    end
  end
end
