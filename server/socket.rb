require 'em-websocket'
require 'json'
require 'set'

require './util'
require './message'

GAME_TICK_TIME_MS = 10

# Note ws.signature is enough to uniquely identify the connection.
class WebSocketServer
   def initialize(host, port)
      @host = host
      @port = port

      @sockets = {}

      # For now, don't queue the player just hold a single waiting player.
      @waitingPlayer = nil

      # {gameId => game}
      @activeGames = {}

      # {playerId => gameId}
      @playerGames = {}

      # Tick all of the games at the same time.
      timerCallback(GAME_TICK_TIME_MS / 1000.0, lambda{
         begin
            tickAll()
         rescue Exception => e
            puts e.message()
            puts e.backtrace.join("\n")
         end
      })

      begin
         # Heads-up: This call blocks until the EM dies.
         EventMachine::WebSocket.start(:host => host, :port => port){|ws|
            ws.onopen{
               onOpen(ws, ws.signature)
            }

            ws.onmessage{|message|
               onMessage(ws.signature, message)
            }

            ws.onclose{
               onClose(ws.signature)
            }

            ws.onerror{|error|
               onError(ws.signature, error)
            }
         }
      rescue Exception => e
         puts e.message()
         puts e.backtrace.join("\n")
      end
   end

   def tickAll()
      # HACK(eriq): Not thread safe.
      @activeGames.each_pair{|id, game|
         game.tick(
            lambda{|moves|
                     moveUpdate(id, moves)
                  },
            lambda{|unitsHit|
                     attackUpdate(id, unitsHit)
                  })
      }
   end

   def attackUpdate(gameId, unitsHit)
      message = JSON.generate({'type' => MESSAGE_TYPE_DAMAGE_UPDATE,
                               'newHealths' => unitsHit[:newHealths],
                               'deadUnitIDs' => unitsHit[:deadUnitIDs]})
      @activeGames[gameId].players.each{|player|
         sendMessage(player, message)
      }
   end

   def moveUpdate(gameId, moves)
      message = JSON.generate({'type' => MESSAGE_TYPE_MOVE_UNITS,
                               'newPositions' => moves})
      @activeGames[gameId].players.each{|player|
         sendMessage(player, message)
      }
   end

   def sendMessage(socketSig, message)
      if (!@sockets[socketSig])
         puts "Closed socket is being referenced"
      else
         @sockets[socketSig].send(message)
      end
   end

   def onOpen(socket, socketSig)
      @sockets[socketSig] = socket

      if (@waitingPlayer != nil)
         newGame = Game.new(@waitingPlayer, socketSig)
         # TEST(chebert)
         #newGame.placeUnitForTesting(Unit.new(@waitingPlayer, 100, 100, 10, 1), 4, 4)
         #sendMessage(@waitingPlayer, JSON.generate({'type' => MESSAGE_TYPE_NEW_UNITS,
                                                    #'newUnits' => [ { 'id' => 0,
                                                                      #'elementType' => 'mailman',
                                                                      #'x' => 4,
                                                                      #'y' => 4 } ] }))
         # TEST

         @activeGames[newGame.id] = newGame

         @playerGames[@waitingPlayer] = newGame.id
         @playerGames[socketSig] = newGame.id

         @waitingPlayer = nil

         # Send the players the init message.
         messageObj = newGame.initMessagePart()
         messageObj['type'] = MESSAGE_TYPE_INIT_GAME

         # First player
         messageObj['playerID'] = newGame.players[0]
         messageObj['opponentIDs'] = [newGame.players[1]]
         message = JSON.generate(messageObj)
         sendMessage(newGame.players[0], message)

         # Second player
         messageObj['playerID'] = newGame.players[1]
         messageObj['opponentIDs'] = [newGame.players[0]]
         message = JSON.generate(messageObj)
         sendMessage(newGame.players[1], message)
      else
         @waitingPlayer = socketSig
      end
   end

   def onClose(socketSig)
      if (@waitingPlayer == socketSig)
         @waitingPlayer = nil
      end

      @sockets.delete(socketSig)

      # Close up an active games
      if (@playerGames.has_key?(socketSig))
         closedGame = @activeGames.delete(@playerGames[socketSig])
         @playerGames.delete(closedGame.players[0])
         @playerGames.delete(closedGame.players[1])
      end
   end

   def onMessage(socketSig, message)
      begin
         obj = JSON.parse(message)
         game = @activeGames[@playerGames[socketSig]]

         case obj['type']
         when MESSAGE_TYPE_MOVE_REQUEST
            game.moveUnits(socketSig, obj['unitIDs'],
                           obj['destx'], obj['desty'])
         when MESSAGE_TYPE_MOVE_IN_RANGE_REQUEST
            # TODO(eriq): Ignored for now.
         when MESSAGE_TYPE_ATTACK_REQUEST
            game.attck(socketSig, obj['targetID'], obj['unitIDs'])
         else
            puts "ERROR: Unknown message type: #{obj['type']}."
         end
      rescue JSON::ParserError => e
         puts e.message()
         puts e.backtrace.join("\n")
      end
   end

   def onError(socketSig, error)
      puts "Socket error: #{error}"
      puts error.backtrace.join("\n")
   end
end
