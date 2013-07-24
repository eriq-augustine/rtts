var make_move_message = function(dx, dy, unitIDs) {
   return {
      dx: dx, // |dx| and |dy| represent the "delta" to move in the x and y directions
      dy: dy,
      unitIDs: unitIDs, // units is a list of unique ids
      type: "move"
   };
};
