require "resolv"

describe "Tokaido::DNS::Table" do
  type = Resolv::DNS::Resource

  types = {
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

  before do
    @table = Tokaido::DNS::Table.new
  end

  types.each do |constant, string|
    it "allows adding #{string} records" do
      @table.add(string, "foo.tok", "127.0.0.1")
      @table.lookup(string, "foo.tok").should == "127.0.0.1"
    end

    it "supports lookup via #{constant}" do
      @table.add(string, "foo.tok", "127.0.0.1")
      @table.lookup(constant, "foo.tok").should == "127.0.0.1"
    end
  end

end
