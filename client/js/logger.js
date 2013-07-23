// No strict mode because of the stack trace generation.

Log = {};

Log.error = function(message) {
   console.log((new Error(message)).stack);
};

Log.debug = function(message) {
   console.log(message);
};
