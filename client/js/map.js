var game = {
   screen: {
      x: 0,
      y: 0,
      w: 50,
      h: 19,
   }
};

var render_elem = function (element, surrounding_elements, is_border, is_screen_border) {
   if (!is_screen_border && !is_border) {
      var found = false;
      for (var i = 0; i < surrounding_elements.length; i++) {
         if (surrounding_elements[i] != element)
            found = true;
      }
      if (!found)
         return " ";
   }
   var clazz = is_screen_border ? "screenBorder" : element;
   switch (element) {
      case "mailman":
         return "<span class='" + clazz + "'>M</span>";
      case "rock":
         return "<span class='" + clazz + "'>r</span>";
      case "tree":
         return "<span class='" + clazz + "'>t</span>";
      case "grass":
         return "<span class='" + clazz + "'>g</span>";
      case "dirt":
         return "<span class='" + clazz + "'>d</span>";
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
      return x == game.screen.x ||
             y == game.screen.y ||
             x == game.screen.x + game.screen.w - 1 ||
             y == game.screen.y + game.screen.h - 1;
   };

   for (var y = game.screen.y; y < (game.screen.y + game.screen.h); y++) {
      for (var x = game.screen.x; x < (game.screen.x + game.screen.w); x++) {
         var elem = map.elements[x + y*width];
         html += render_elem(elem, surrounding_elems(x, y, map), is_border(x, y));
      }
      html += "\n";
   }
   mapDiv.innerHTML = html;
};

var render_mini_map = function(map) {
   var mapDiv = $("#miniMap")[0];
   var width = map.size.x;
   var height = map.size.y;
   var html = "";
   var is_border = function (x, y) {
      return x == 0 ||
             y == 0 ||
             x == width - 1 ||
             y == height - 1;
   };

   var is_screen_border = function (x, y) {
      return (x == game.screen.x || x == game.screen.x + game.screen.w - 1) &&
             (y >= game.screen.y && y <= game.screen.y + game.screen.h - 1) ||
             (y == game.screen.y || y == game.screen.y + game.screen.h - 1) &&
             (x >= game.screen.x && x <= game.screen.x + game.screen.w - 1);
   };

   for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
         var elem = map.elements[x + y*width];
         html += render_elem(elem,
                             surrounding_elems(x, y, map),
                             is_border(x, y),
                             is_screen_border(x, y));
      }
      html += "\n";
   }
   mapDiv.innerHTML = html;
};

var move_screen_by = function(dx, dy) {
   // Inclusive clamp.
   var clamp = function(val, low, hi) {
      if (val < low) return low;
      if (val > hi)  return hi;
      else           return val;
   };
   game.screen.x += dx;
   game.screen.y += dy;

   game.screen.x = clamp(game.screen.x, 0, game.currentMap.size.x - game.screen.w);
   game.screen.y = clamp(game.screen.y, 0, game.currentMap.size.y - game.screen.h);
};
