// Test
var mapJSON = {
   "size": {
      "x": 5,
      "y": 8
   },
   "elements": [
      "rock",
      "rock",
      "rock",
      "rock",
      "rock",

      "tree",
      "tree",
      "tree",
      "tree",
      "tree",

      "grass",
      "grass",
      "grass",
      "grass",
      "grass",

      "grass",
      "grass",
      "grass",
      "grass",
      "grass",

      "grass",
      "grass",
      "grass",
      "grass",
      "grass",

      "grass",
      "grass",
      "grass",
      "grass",
      "grass",


      "dirt",
      "dirt",
      "dirt",
      "dirt",
      "dirt",

      "grass",
      "dirt",
      "tree",
      "rock",
      "dirt"
   ]
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
      case "rock":
         return "<span class='rock'>r</span>";
      case "tree":
         return "<span class='tree'>t</span>";
      case "grass":
         return "<span class='grass'>g</span>";
      case "dirt":
         return "<span class='dirt'>d</span>";
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

var render_map = function() {
   var map = $("#map")[0];
   var width = mapJSON["size"]["x"];
   var height = mapJSON["size"]["y"];
   var html = "";
   var is_border = function (x, y) {
      return x == 0 || y == 0 || x == width - 1 || y == height - 1;
   };

   for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
         var elem = mapJSON["elements"][x + y*width];
         html += render_elem(elem, surrounding_elems(x, y, mapJSON), is_border(x, y));
      }
      html += "\n";
   }
   map.innerHTML = html;
};

var main = function() {
   render_map();
};

window.onload = main;
