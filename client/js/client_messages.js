var messageIncrementer = 0;
var Message = {};
Message.TYPE_MOVE_REQUEST = messageIncrementer++;
Message.TYPE_MOVE_UNITS   = messageIncrementer++;
Message.TYPE_NEW_UNITS    = messageIncrementer++;
Message.NUM_TYPES         = messageIncrementer++;

var make_move_request_message = function(destx, desty, unitIDs) {
   return {
      destx: destx,
      desty: desty,
      unitIDs: unitIDs,
      type: Message.TYPE_MOVE_REQUEST
   };
};
