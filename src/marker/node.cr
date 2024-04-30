module Marker
  abstract class Node
  end

  class SyntaxTree
    property nodes : Array(Node)

    def initialize(@nodes)
    end
  end

  class Block < Node
  end

  class Inline < Node
  end

  class Heading < Block
    property level : Int32
    property value : Array(Inline)

    def initialize(@level, @value)
    end
  end

  # TODO: isn't this technically a block?
  class Paragraph < Inline
    property value : Array(Inline)

    def initialize(@value)
    end
  end

  class Text < Inline
    property value : String

    def initialize(@value)
    end
  end

  class Strong < Inline
    enum Kind
      Asterisk
      Underscore
    end

    property kind : Kind
    property value : Array(Inline)

    def initialize(@kind, @value)
    end
  end

  class Emphasis < Inline
    enum Kind
      Asterisk
      Underscore
    end

    property kind : Kind
    property value : Array(Inline)

    def initialize(@kind, @value)
    end
  end

  class CodeSpan < Inline
    property value : String

    def initialize(@value)
    end
  end

  class CodeBlock < Inline
    enum Kind
      Backtick
      Tilde
    end

    property kind : Kind
    property info : String?
    property value : String

    def initialize(@kind, @info, @value)
    end
  end

  class BlockQuote < Block
    property value : Array(Inline)

    def initialize(@value)
    end
  end

  class List < Block
    property items : Array(Node)
    property? ordered : Bool

    def initialize(@items, @ordered)
    end
  end
end
