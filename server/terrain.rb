TERRAIN_TYPE_PLAIN = 0
TERRAIN_NUM_TYPES = 1

class Terrain < BoardPiece
   attr_reader :type

   def initialize(type)
      super(false)

      @type = type
   end

   def to_s
      # TODO(eriq)
      return @type[0].upcase
   end
end
