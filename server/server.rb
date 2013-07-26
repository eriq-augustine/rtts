require './socket'
require './game'

Board::loadFromFile('../maps/dirtNGrass.json', 0, 1)

serverInstance = WebSocketServer.new('localhost', '12345')
