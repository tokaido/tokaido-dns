require "resolv"
require "socket"

module Tokaido
  module DNS
    class Server
      LOCALHOST = "127.0.0.1".freeze

      # Note: It is perfectly fine and desirable for the table to change
      # throughout the lifetime of the server
      def initialize(table, port)
        @table = table
        @port = port
      end

      def start
        @server = UDPSocket.open
        @server.bind LOCALHOST, port
        Thread.new { process_requests }
      end

      def stop

      end

    private
      def process_requests
        loop do
          query, from = next_query

          message = query.respond do |question, response|
            next unless question.type == "A"

            response.data = LOCALHOST
            response.ttl = 60
          end

          send_to from, message.encode
        end
      ensure
        @server.close
      end

      def next_query
        # from is [ family, port, host, ip ]
        data, from = @server.recvfrom(1024)

        [ Query.decode(data), from ]
      end

      def send_to(to, data)
        # extract host, port
        @server.send data, to[2], to[1]
      end
    end
  end
end
