require 'set'

# This will not block.
# Returns true on success.
# Failure of this function is probably because the lambda takes more than 1 parameter.
# |callbackLambda| must return true to get called again.
def timerCallback(interval, callbackLambda)
   if (!callbackLambda || callbackLambda.arity != 0)
      return false
   end

   Thread.new{
      while true
         # Seeing some more consistent results with select than with sleep.
         select(nil, nil, nil, interval)

         if (!callbackLambda.call())
            break
         end
      end
   }

   return true
end

def manhattanDistance(x, y)
   return (x[:row] - y[:row]).abs() + (x[:col] - y[:col]).abs()
end

# |start| and |dest| should be {:row => int, :col => int}.
def aStar(board, start, dest)
   visited = Set.new()
   toVisit = []
   toVisitSet = Set.new()
   # {node => node}
   reverseTraversals = {}

   # Cost along the best known path.
   gScore = {}
   # Estimated cost.
   fScore = {}

   gScore[start] = 0
   fScore[start] = gScore[start] + aStarHeuristic(start, dest)
   toVisitSet << start
   aStarOrderedInsert(toVisit, {:score => fScore[start], :node => start})

   while (!toVisit.empty?)
      current = toVisit.shift()[:node]
      toVisitSet.delete(current)
      if (current == dest)
         return aStarReconstruct(reverseTraversals, dest)
      end

      visited << current

      neighbors = getNeighbors(board, current)
      neighbors.each{|neighbor|
         # Note(eriq): All adjacenet distances are currently 1.
         newGScore = gScore[current] + 1
         if (visited.include?(neighbor) && newGScore > gScore[neighbor]
            # Ignore, already have a better path to this node.
            next
         end

         if (!toVisitSet.include?(neighbor) || newGScore < gScore[neighbor])
            reverseTraversals[neighbor] = current
            gScore[neighbor] = newGScore
            fScore[neighbor] = gScore[neighbor] + aStarHeuristic(neighbor, dest)
            if (!toVisitSet.include?(neighbor))
               toVisitSet << neighbor
               aStarOrderedInsert(toVisit, {:score => fScore[neighbor], :node => neighbor})
            end
         end
      }
   end

   # No path
   return nil
end

def getNeighbors(board, node)
   orientations = [[0, 1], [0, -1], [1, 0], [-1, 0]]

   neighbors = []

   orientations.each{|orientation|
      newRow = node[:row] + orientation[0]
      newCol = node[:col] + orientation[1]

      if (newRow >= 0 && newRow < board.height &&
          newCol >= 0 && newCol < board.width &&
          !board.occupied(newRow, newCol))
         neightbors << {:row => newRow, :col => newCol}
      end
   }

   return neighbors
end

# Remember, h(x) <= d(x, y) + h(y)
#  (This must never over estimate).
# Just use Manhattan distance.
def aStarHeuristic(x, dest)
   return manhattanDistance(x, dest)
end

def aStarReconstruct(reverseTraversals, current)
   if (reverseTraversals.has_key?(current))
      return aStarReconstruct(reverseTraversals, reverseTraversals[current]) + current
   else
      return [current]
   end
end

# Assumes |value| is a map with a :score field.
def aStarOrderedInsert(list, value)
   insertPosition = 0
   while (insertPosition < list.length() && list[insertPosition][:score] < value[:score])
      insertPosition += 1
   end

   list.insert(insertPosition, value)
end
