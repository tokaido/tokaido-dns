require "resolv"
require "socket"

module Tokaido
  module DNS
    class Server
      # Note: It is perfectly fine and desirable for the table to change
      # throughout the lifetime of the server
      def initialize(table, port)
        @table = table
        @port = port
      end

      def start
        @server = UDPSocket.open
        @server.bind "127.0.0.1", port
        Thread.new { process_requests }
      end

      def stop

      end

    private
      def process_requests
        loop do
          msg, from = read_msg
        end
      ensure
        @server.close
      end
    end
  end
end
