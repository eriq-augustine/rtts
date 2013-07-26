class Unit < BoardPiece
   @@nextId = 0

   attr_reader :id, :type, :moveSpeed, :attack, :attackSpeed, :range, :owner
   attr_accessor :hp

   def initialize(type, owner, hp, moveSpeed, attack, attackSpeed, range)
      super(true)

      @id = @@nextId
      @@nextId += 1

      @type = type
      @owner = owner

      @hp = hp
      @moveSpeed = moveSpeed
      @attack = attack
      @attackSpeed = attackSpeed
      @range = range
   end

   def to_s
      # TODO(eriq)
      return @type[0].upcase
   end
end

def makeUnit(owner, type)
   case type
   when 'clown'
      return Unit.new(type, owner, 100, 500, 10, 500, 1)
   else
      puts "ERROR: Unknown unit type: '#{type}'."
      return nil
   end
end
