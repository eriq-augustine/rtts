require './board'

require 'set'

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

      # {id => {:unit => unit, :position => {:row => int, :col => int}}}
      @units = {}

      # {id => {:lastMoved => int, :destination => {:row => int, :col => int}, :path => [{:row => int, :col => int}, ...]}}
      @movingUnits = {}

      # {id => {:lastAttack => int, :target => id}}
      @attackingUnits = {}

      @gameTime = 0
   end

   # Main game advance
   def tick()
      @gameTime += 1

      updateMovements()
   end

   # TODO(eriq): Paths may have to be recomputed as other units move.
   #  It is also possible that the path does not lead to the true
   #  destination (if it was occupied when the path was built).
   #  In this case, the entire path should be rebuilt.
   def updateMovements()
      toRemove = []
      moved = false

      @movingUnits.each_pair{|id, moveInfo|
         unit = @units[id]
         target = moveInfo[:path][0]

         if (!unit ||
             @gameTime - moveInfo[:lastMoved] < unit.moveSpeed ||
             @board.occupied?(target[:row], target[:col]))
            next
         end

         @board.move(unit[:position][:row], unit[:position][:col],
                     target[:row], target[:col])
         unit[:position] = target
         moveInfo[:path].shift()

         if (moveInfo[:path].empty?)
            toRemove << id
         end

         moved = true
      }

      toRemove.each{|id|
         @movingUnits.delete(id)
      }

      return moved
   end

   # TODO(eriq): This will have to pathfind to the target.
   def moveUnits(playerId, ids, targetRow, targetCol)
      ids.each{|unitId|
         if (@units.has_key?(unitId) && playerId == @units[unitId][:unit].id)
            moveUnit(unitId, targetRow, targetCol)
         end
      }
   end

   def moveUnit(id, targetRow, targetCol)
      if (!@units.has_key?(id) ||
          !@board.inBounds?(targetRow, targetCol))
         return false
      end

      unit = @units[id]

      # Remove any previous movement or atacking orders for this unit.
      @movingUnits.delete(id)
      @attackingUnits.remove(id)

      target = getTargetLocation(unit[:position][:row], unit[:position][:col],
                                 row, col)

      if (!target)
         return false
      end

      path = aStar(@board, unit[:position], target)

      if (!path)
         return false
      end

      # Note(eriq): Units do not get to immediatley move,
      #  they must wait the full move duration before actually moving initially.
      @movingUnits[unit[:unit].id] = {:lastMoved => @gameTime,
                               :destination => {:row => targetRow, :col => targetCol},
                               :path = path}

      return true
   end

   # A unit can not always move to where is wants. In this case, move
   #  it to some other location near the target.
   def getTargetLocation(sourceRow, sourceCol, desiredRow, desiredCol)
      visited = Set.new()
      toVisit = []

      toVisit << {:row => desiredRow, :col => desiredCol}

      while (!toVisit.empty?)
         current = toVisit.shift()
         visited.add(current)

         if (!@board.occupied?(current[:row], current[:col]))
            return current
         end

         # TODO(eriq): Ideally, locations closer to the player will be
         #  chosen/examined first.
         toVisit.concat(getNeighbors(@board, current))
      end

      # There is nowhere to move :(
      return nil
   end
end
