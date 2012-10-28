# This turned out not to be necessary for Tokaido but it might
# be useful for someone so I'm leaving it here.

module Tokaido
  module DNS
    class Table
      def initialize
        @table = Hash.new { |h,k| h[k] = {} }
      end

      def add(type, domain, *payload)
        @table[type][domain] = payload
      end

      def remove(type, domain)
        type = normalize(type)
        @table[type].delete(domain)
      end

      def lookup(type, domain)
        type = normalize(type)
        @table[type][domain]
      end

    private
      def normalize(type)
        return type if type.is_a?(String)

        TYPES[type]
      end
    end
  end
end
