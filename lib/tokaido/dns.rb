require "tokaido/dns/version"
require "tokaido/dns/server"
require "tokaido/dns/table"
require "tokaido/dns/query"

module Tokaido
  module DNS
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
  end
end

