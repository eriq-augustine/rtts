var Message = {};
Message.TYPE_MOVE = 0;
Message.NUM_TYPES = 1;

var make_move_message = function(destx, desty, unitIDs) {
   return {
      destx: destx, // |destx| and |desty| represent the desired destination for the units.
      desty: desty,
      unitIDs: unitIDs, // units is a list of unique ids
      type: Message.TYPE_MOVE
   };
};
