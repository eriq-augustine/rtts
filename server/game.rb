require './board'

DEFAULT_BOARD_HEIGHT = 10
DEFAULT_BOARD_WIDTH = 10

class Game
   def initialize()
      @board = Board.new(DEFAULT_BOARD_HEIGHT, DEFAULT_BOARD_WIDTH)
   end

   # Main game advance
   def tick()
   end

   # TODO(eriq): This will have to pathfind to the target.
   def moveUnit(startRow, startCol, endRow, endCol)
   end
end
