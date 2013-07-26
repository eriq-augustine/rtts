class Unit < BoardPiece
   @@nextId = 0

   attr_reader :id, :moveSpeed, :attack, :attackSpeed, :range, :owner
   attr_accessor :hp

   def initialize(owner, hp, moveSpeed, attack, attackSpeed, range)
      super(true)

      @id = @@nextId
      @@nextId += 1

      @owner = owner

      @hp = hp
      @moveSpeed = moveSpeed
      @attack = attack
      @attackSpeed = attackSpeed
      @range = range
   end

   def to_s
      # TODO(eriq)
      return 'U'
   end
end
