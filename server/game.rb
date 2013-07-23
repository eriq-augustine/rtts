require './board'

DEFAULT_BOARD_HEIGHT = 10
DEFAULT_BOARD_WIDTH = 10

class Game
   @@nextGame = 0

   attr_reader :id, :players

   def initialize(player1Id, player2Id)
      @id = @@nextGame
      @@nextGame += 1

      @board = Board.new(DEFAULT_BOARD_HEIGHT, DEFAULT_BOARD_WIDTH)

      @players = [player1Id, player2Id]
   end

   # Main game advance
   def tick()
   end

   # TODO(eriq): This will have to pathfind to the target.
   def moveUnit(startRow, startCol, endRow, endCol)
   end
end
