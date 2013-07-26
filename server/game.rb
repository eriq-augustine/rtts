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

      @board, initUnits = Board::loadFromFile('../maps/dirtNGrass.json',
                                             player1Id, player2Id)

      @players = [player1Id, player2Id]

      # {id => {:unit => unit, :position => {:row => int, :col => int}}}
      @units = {}

      # Place the initial units from the board initialization.
      initUnits.each{|unit|
         @units[unit[:unit].id] = unit
      }

      # {id => {:lastMoved => int, :destination => {:row => int, :col => int}, :path => [{:row => int, :col => int}, ...]}}
      @movingUnits = {}

      # {id => {:lastAttack => int, :target => id}}
      @attackingUnits = {}

      @gameTime = 0
   end

   # Main game advance
   def tick(moveCallback, attackCallback)
      @gameTime += 1

      unitsHit = updateAttacks()
      if (!unitsHit[:deadUnitIDs].empty? || !unitsHit[:newHealths].empty?)
         attackCallback.call(unitsHit)
      end

      moves = updateMovements()
      if (!moves.empty?)
         moveCallback.call(moves)
      end
   end

   # TODO(eriq): Paths may have to be recomputed as other units move.
   #  It is also possible that the path does not lead to the true
   #  destination (if it was occupied when the path was built).
   #  In this case, the entire path should be rebuilt.
   def updateMovements()
      toRemove = []
      moves = []

      @movingUnits.each_pair{|id, moveInfo|
         unit = @units[id]
         target = moveInfo[:path][0]

         # Unit is gone. Killed?
         if (!unit)
            toRemove << id
            next
         end

         if (@gameTime - moveInfo[:lastMoved] < unit[:unit].moveSpeed ||
             # TODO(eriq): If the next location for this unit is occupied, just wait.
             #  If the spot if occupied by a unit that is not moving, the path should probably be recalculated.
             @board.occupied?(target[:row], target[:col]))
            next
         end

         @board.move(unit[:position][:row], unit[:position][:col],
                     target[:row], target[:col])
         unit[:position] = target
         moveInfo[:path].shift()
         moveInfo[:lastMoved] = @gameTime

         if (moveInfo[:path].empty?)
            toRemove << id
         end

         moves << {'id' => unit[:unit].id,
                   'x' => target[:row],
                   'y' => target[:col]}
      }

      toRemove.each{|id|
         @movingUnits.delete(id)
      }

      return moves
   end

   def updateAttacks()
      # TODO(eriq): Make sure to move the unit if out of range.
      toRemove = []
      # {:deadUnitIDs => [id, ...], :newHealths => [{'id' => id, 'health' => health}, ...]}
      unitsHit = {:deadUnitIDs => [], :newHealths => {}}

      @attackingUnits.each_pair{|id, attackInfo|
         unit = @units[id]
         target = @units[attackInfo[:target]]

         # Someone died.
         if (!unit || !target)
            toRemove << id
            next
         end

         # The target moved out of range, try moving to the target and attack again.
         # Note that this check is before the attack speed check.
         # TODO(eriq): The unit should probably just move in range instead of all the way to the target.
         if (manhattanDistance(unit[:position], target[:position]) > unit[:unit].range)
            moveUnit(id, target[:position][:row], target[:position][:col])
            next
         end

         if (@gameTime - attackInfo[:lastAttack] < unit[:unit].attackSpeed)
            next
         end

         target[:unit].hp -= unit[:unit].attack
         if (target[:unit].hp <= 0)
            killUnit(attackInfo[:target])
            unitsHit[:deadUnitIDs] << attackInfo[:target]

            # Remove the attacker from the attacking list.
            toRemove << id
         else
            unitsHis[:newHealths] << {'id' => [attackInfo[:target]], 'health' => target[:unit].hp}
         end
      }

      toRemove.each{|id|
         @attackingUnits.delete(id)
      }

      return unitsHit
   end

   def killUnit(id)
      unit = @units.delete(id)
      @attackingUnits.delete(id)
      @movingUnits.delete(id)
      @board.remove(unit[:position][:row], unit[:position][:col])
   end

   def attack(playerId, targetId, unitIds)
      # Note(eriq): This check disallows friendly fire.
      if (!@units.has_key?(targetId) || @units[targetId][:unit].owner == playerId)
         return
      end

      unitIds.each{|unitId|
         if (!@units.has_key?(unitId) || @units[unitId][:unit].owner != playerId)
            next
         end

         # Remove any previous orders this unit has.
         @movingUnits.delete(unitId)
         @attackingUnits.delete(unitId)

         # Range check. If out of range, then just move TO the unit.
         # TODO(eriq): Move to a better location. Range units will probably want to move to minumum range.
         if (manhattanDistance(@units[targetId][:position], @units[unitId][:position]) > @units[unitId][:unit].range)
            moveUnit(unitId, @units[targetId][:position][:row], @units[targetId][:position][:col])
         else
            @attackingUnits[unitId[:unit].id] = {:lastAttack => @gameTime, :target => targetId}
         end
      }
   end

   def moveUnits(playerId, ids, targetRow, targetCol)
      ids.each{|unitId|
         if (@units.has_key?(unitId) &&
             playerId == @units[unitId][:unit].owner)
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
      @attackingUnits.delete(id)

      target = getTargetLocation(unit[:position][:row], unit[:position][:col],
                                 targetRow, targetCol)

      if (!target)
         return false
      end

      path = aStar(@board, unit[:position], target)

      if (!path)
         return false
      end

      # Remove the unit origin from the path.
      path.shift()

      # Note(eriq): Units do not get to immediatley move,
      #  they must wait the full move duration before actually moving initially.
      @movingUnits[unit[:unit].id] =
         {:lastMoved => @gameTime,
          :destination => {:row => targetRow, :col => targetCol},
          :path => path}

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

   def placeUnitForTesting(unit, row, col)
      @board.placePieceForTesting(row, col, unit)
      @units[unit.id] = {:unit => unit, :position => {:row => row, :col => col}}
   end
end
