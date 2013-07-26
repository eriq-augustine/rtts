var Message = {};
Message.incrementer = 0;
Message.TYPE_MOVE_REQUEST = Message.incrementer++;
Message.TYPE_MOVE_UNITS   = Message.incrementer++;
Message.TYPE_NEW_UNITS    = Message.incrementer++;
Message.NUM_TYPES         = Message.incrementer++;

var make_move_request_message = function(destx, desty, unitIDs) {
   return JSON.stringify({
      destx: destx,
      desty: desty,
      unitIDs: unitIDs,
      type: Message.TYPE_MOVE_REQUEST
   });
};
