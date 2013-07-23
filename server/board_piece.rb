class BoardPiece
   def initialize(moveable)
      @moveable = moveable
   end

   def moveable?
      return @moveable
   end

   def to_s
      return '?'
   end
end

# TODO(eriq): Perhaps handle loading in a central location.
#  This may get very messy very fast otherwise.
require './unit'
require './terrain'
