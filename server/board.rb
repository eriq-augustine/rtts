require './board_piece'

class Board
   attr_reader :height, :width

   def initialize(height, width)
      @height = height
      @width = width

      @board = Array.new(height)
      for row in 0...height
         @board[row] = Array.new(width)
      end
   end

   def move(startRow, startCol, endRow, endCol)
      if (!@board[startRow][startCol] ||
          !@board[startRow][startCol].moveable? ||
          @board[endRow][endCol])
         return
      end

      @board[endRow][endCol] = @board[startRow][startCol]
      @board[startRow][startCol] = nil
   end

   def occupied?(row, col)
      return @board[row][col] != nil
   end

   def inBounds?(row, col)
      return row >= 0 && row < @height &&
             col >= 0 && col < @width
   end

   def remove(row, col)
      @board[row][col] = nil
   end

   def to_s
      @board.each{|row|
         print '|'

         row.each{|col|
            if (col)
               print "#{col}|"
            else
               print " |"
            end
         }

         puts ''
      }
   end

   # Note: This should only be used for testing.
   #  Real boards should probably be deserialized from some static source.
   def placePieceForTesting(row, col, piece)
      @board[row][col] = piece
   end
end
