var game = {
   player: {
      units: [
         {
            id: "micky",
            x: 1,
            y: 1,
            elementType: "mailman"
         }
      ],
      currentSelection: [
      ]
   },
   currentMap: {}
};

var render_elem = function (element, surrounding_elements, is_border) {
   if (!is_border) {
      var found = false;
      for (var i = 0; i < surrounding_elements.length; i++) {
         if (surrounding_elements[i] != element)
            found = true;
      }
      if (!found)
         return " ";
   }
   switch (element) {
      case "mailman":
         return "<span class='mailman'>M</span>";
      case "rock":
         return "<span class='rock'>r</span>";
      case "tree":
         return "<span class='tree'>t</span>";
      case "grass":
         return "<span class='grass'>g</span>";
      case "dirt":
         return "<span class='dirt'>d</span>";
      default:
         return "X";
   }
};

var surrounding_elems = function(x, y, json) {
   var width = json["size"]["x"];
   var height = json["size"]["y"];
   var elems = [];
   if (x > 0) {
      elems.push(json["elements"][x - 1 + y*width]);
      if (y > 0) elems.push(json["elements"][x - 1 + (y - 1)*width]);
      if (y < height - 1) elems.push(json["elements"][x - 1 + (y + 1)*width]);
   }
   if (x < width - 1) {
      elems.push(json["elements"][x + 1 + y*width])
      if (y > 0) elems.push(json["elements"][x + 1 + (y - 1)*width]);
      if (y < height - 1) elems.push(json["elements"][x + 1 + (y + 1)*width]);
   }
   if (y > 0)          elems.push(json["elements"][x + (y - 1)*width])
   if (y < height - 1) elems.push(json["elements"][x + (y + 1)*width])
   return elems;
};

var render_map = function(map) {
   var mapDiv = $("#map")[0];
   var width = map.size.x;
   var height = map.size.y;
   var html = "";
   var is_border = function (x, y) {
      return x == 0 || y == 0 || x == width - 1 || y == height - 1;
   };

   for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
         var elem = map.elements[x + y*width];
         html += render_elem(elem, surrounding_elems(x, y, map), is_border(x, y));
      }
      html += "\n";
   }
   mapDiv.innerHTML = html;
};

var remove_units_from_current_map = function(units) {
   for (var i = 0; i < units.length; i++) {
      var ndx = units[i].x + units[i].y * game.currentMap.size.x;
      game.currentMap.elements[ndx] = game.originalMap.elements[ndx];
   }
};

var add_units_to_current_map = function(units) {
   for (var i = 0; i < units.length; i++)
      game.currentMap.elements[units[i].x + units[i].y * game.currentMap.size.x] = units[i].elementType;
   return map;
};

var cloneMap = function(json) {
   var newJson = { elements: []};
   newJson.size = json.size;
   for (var i = 0; i < json.elements.length; i++)
      newJson.elements.push(json.elements[i]);
   return newJson;
};

var update_units_positions = function(newPositions) {
   var units = [];
   var getPlayerUnit = function (id) {
      for (var i = 0; i < game.player.units.length; i++) {
         if (game.player.units[i].id == id)
            return game.player.units[i];
         Log.debug("Error, unit not found");
      }
   };
   for (var i = 0; i < newPositions.length; i++)
      units.push(getPlayerUnit(newPositions[i].id));
   remove_units_from_current_map(units);
   for (var i = 0; i < units.length; i++) {
      units[i].x = newPositions[i].x;
      units[i].y = newPositions[i].y;
   }
   add_units_to_current_map(units);
};

var select_all_units_by_type = function(elementType) {
   game.player.currentSelection = [];
   for (var i = 0; i < game.player.units.length; i++) {
      if (game.player.units[i].elementType == elementType) {
         game.player.currentSelection.push(game.player.units[i].id);
      }
   }
   Log.debug(game.player.currentSelection);
};

var handle_terminal_input = function() {
   var splitCommand = $("#terminal").val().split(" ");
   if (splitCommand.length < 1) return;

   var command = splitCommand[0].toLowerCase();
   if (command == "select") {
      if (splitCommand.length < 3 || splitCommand[1] != "all") {
         Log.debug("usage: select all <unit type>");
      } else {
         select_all_units_by_type(splitCommand[2].toLowerCase());
      }
   } else if (command == "move") {
      if (game.player.currentSelection.length == 0) {
         Log.debug("Must make a selection before moving.");
      } else if (splitCommand.length < 3) {
         Log.debug("Usage: move <destx> <desty>");
      } else {
         var destx = parseInt(splitCommand[1]);
         var desty = parseInt(splitCommand[2]);
         game.socket.send(make_move_message(destx, desty, game.player.currentSelection));
      }
   } else {
   }
   $("#terminal").val("");
};

var main = function() {
   game.socket = new Socket();
   game.originalMap = mapJSON;
   game.currentMap = cloneMap(mapJSON);

   $("#terminal").keydown(function (eventObject) {
      if (eventObject.keyCode == 13) {
         handle_terminal_input();
      }
   });
   add_units_to_current_map(game.player.units);
   // Test
   game.socket.onMessage({data: {type: "moveUnits", newPositions: [{id: "micky", x: 2, y: 2}]}});
   // Test
   render_map(game.currentMap);
};

window.onload = main;
