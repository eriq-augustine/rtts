#!/usr/bin/python2
import Image
import json

def translate_pixel(pix):
   if pix == (0, 255, 1):
      return "grass"
   elif pix == (0, 133, 0):
      return "tree"
   elif pix == (133, 133, 0):
      return "dirt"
   elif pix == (0, 0, 0):
      return "rock"

def elements(pixels, width, height):
   elems = []
   for y in range(height):
      for x in range(width):
         elems.append(translate_pixel(pixels[x,y]))
   return elems

def main():
   image = Image.open("test.jpg")
   pixels = image.load()
   w, h = image.size
   print("var mapJSON = ")
   print(json.dumps({"size": {"x": w, "y": h}, "elements": elements(pixels, w, h)},
                    indent=4,
                    separators=(',', ': ')))

if __name__ == "__main__":
   main()
