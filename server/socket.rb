require 'em-websocket'
require 'json'
require 'set'

# Note ws.signature is enough to uniquely identify the connection.
class WebSocketServer
   def initialize(host, port)
      @host = host
      @port = port

      @sockets = {}

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

      # TODO(eriq): on open
      puts "Open: #{socketSig}."
   end

   def onClose(socketSig)
      # TODO(eriq): on close
      puts "Close: #{socketSig}."
   end

   def onMessage(socketSig, message)
      begin
         obj = JSON.parse(message)

         # TODO(eriq): Parse message
         sendMessage(socketSig, JSON.generate({'type' => 'echo',
                                               'msg' => message}))
      rescue JSON::ParserError => e
         puts e.message()
         puts e.backtrace.join("\n")
      end
   end

   def onError(socketSig, error)
      puts "Socket error: #{error}"
   end
end
