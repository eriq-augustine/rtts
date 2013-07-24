var make_move_message = function(destx, desty, unitIDs) {
   return {
      destx: destx, // |destx| and |desty| represent the desired destination for the units.
      desty: desty,
      unitIDs: unitIDs, // units is a list of unique ids
      type: "move"
   };
};
