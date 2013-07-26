require './board_piece'

class Board
   attr_reader :height, :width

   def initialize(height, width)
      @height = height
      @width = width

      @terrainLayer = Array.new(height)
      # Includes units and obstructions.
      @objectLayer = Array.new(height)

      for row in 0...height
         @terrainLayer[row] = Array.new(width)
         @objectLayer[row] = Array.new(width)
      end
   end

   def move(startRow, startCol, endRow, endCol)
      if (!@objectLayer[startRow][startCol] ||
          !@objectLayer[startRow][startCol].moveable? ||
          @objectLayer[endRow][endCol])
         return
      end

      @objectLayer[endRow][endCol] = @objectLayer[startRow][startCol]
      @objectLayer[startRow][startCol] = nil
   end

   def occupied?(row, col)
      return @objectLayer[row][col] != nil
   end

   def inBounds?(row, col)
      return row >= 0 && row < @height &&
             col >= 0 && col < @width
   end

   def remove(row, col)
      @objectLayer[row][col] = nil
   end

   def to_s
      for row in 0...@height
         print '|'
         for col in 0...@width
            if (@objectLayer[row][col])
               print "#{@objectLayer[row][col]}"
            else
               print "#{@terrainLayer[row][col]}"
            end
            print '|'
         end
         puts ''
      end
   end

   # Note: This should only be used for testing.
   #  Real boards should probably be deserialized from some static source.
   def placePieceForTesting(row, col, piece)
      @objectLayer[row][col] = piece
   end

   def self.loadFromFile(fileName, player1Id, player2Id)
      file = File.open(fileName)
      mapObject = JSON.load(file)
      file.close()

      height = mapObject['size']['y']
      width = mapObject['size']['x']

      terrainLayer = Array.new(height)
      # Includes units and obstructions.
      objectLayer = Array.new(height)

      for row in 0...height
         terrainLayer[row] = Array.new(width)
         objectLayer[row] = Array.new(width)
      end

      for i in 0...mapObject['elements'].length
         row = i / width
         col = i - row * width

         terrainLayer[row][col] = Terrain.new(mapObject['elements'][i])
      end

      mapObject['units'].each{|unit|
         owner = unit['owner'] == 0 ? player1Id : player2Id
         newUnit = makeUnit(owner, unit['type'])
         objectLayer[unit['x']][unit['y']] = newUnit
      }

      newBoard = Board.new(height, width)
      newBoard.setTerrain(terrainLayer)
      newBoard.setObjects(objectLayer)

      return newBoard
   end

   def setTerrain(terrain)
      @terrainLayer = terrain
   end

   def setObjects(objects)
      @objectLayer = objects
   end
end
