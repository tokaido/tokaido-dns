require "resolv"
require "socket"

module Tokaido
  module DNS
    class Server
      IPv4 = "127.0.0.1".freeze
      IPv6 = Addrinfo.getaddrinfo(nil, 80, "PF_INET6", :STREAM)[0].ip_address.freeze

      def initialize(port)
        @port = port
        @stopped = false
      end

      def start
        puts "Starting DNS Server"
        @server = UDPSocket.open
        @server.bind IPv4, @port
        Thread.new { process_requests }
      end

      def stop
        puts "Stopping DNS Server"
        @stopped = true
      end

    private
      def process_requests
        loop do
          query, from = next_query

          break if @stopped

          message = query.respond do |question, response|
            if question.type == "A"
              response.data = IPv4
            elsif question.type == "AAAA"
              response.data = IPv6
            else
              response.not_found!
              next
            end

            response.ttl = 60
          end

          send_to from, message.encode
        end
      ensure
        @server.close
      end

      def next_query
        loop do
          return if @stopped
          next unless IO.select([@server], [], [], 1)

          # from is [ family, port, host, ip ]
          data, from = @server.recvfrom_nonblock(1024)

          return [ Query.decode(data), from ]
        end
      rescue IO::WaitReadable
        retry
      end

      def send_to(to, data)
        # extract host, port
        @server.send data, 0, to[2], to[1]
      end
    end
  end
end
