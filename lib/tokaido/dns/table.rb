require "resolv"

module Tokaido
  module DNS
    class Table
      def initialize
        @table = Hash.new { |h,k| h[k] = {} }
      end

      def add(type, domain, ip)
        @table[type][domain] = ip
      end

      def lookup(type, domain)
        type = normalize(type)
        @table[type][domain]
      end

    private
      type = Resolv::DNS::Resource

      TYPES = {
        type::IN::A => "A",
        type::IN::AAAA => "AAAA",
        type::IN::SRV => "SRV",
        type::IN::WKS => "WKS",
        type::MINFO => "MINFO",
        type::MX => "MX",
        type::NS => "NS",
        type::PTR => "PTR",
        type::SOA => "SOA",
        type::TXT => "TXT"        
      }

      def normalize(type)
        return type if type.is_a?(String)

        TYPES[type]
      end
    end
  end
end
