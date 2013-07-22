"use strict";

Socket.SERVER = 'ws://localhost:12345/websocket';

function Socket() {
   this.ws = new WebSocket(Socket.SERVER);

   this.ws.onmessage = this.onMessage.bind(this);
   this.ws.onclose = this.onClose.bind(this);
   this.ws.onopen = this.onOpen.bind(this);
   this.ws.onerror = this.onError.bind(this);
}

Socket.prototype.onMessage = function(messageEvent) {
   // TEST
   console.log("on message");
   console.log(messageEvent.data);

   var message = null;
   try {
      message = JSON.parse(messageEvent.data);
   } catch (ex) {
      Log.error('Server message does not parse.');
      return false;
   }

   switch (message.type) {
      case 'echo':
         break;
      default:
         // Note: There are message types that are known, but just not expected from the server.
         Log.error('Unknown Message Type: ' + message.type);
         break;
   }
};

Socket.prototype.onClose = function(messageEvent) {
   Log.debug("Connection to server closed.");
};

Socket.prototype.onOpen = function(chosenPattern, messageEvent) {
   Log.debug("Connection to server opened.");
};

Socket.prototype.onError = function(messageEvent) {
   Log.error(JSON.stringify(messageEvent));
};

Socket.prototype.close = function() {
   this.ws.close();
};
