require "resolv"

# See http://www.networksorcery.com/enp/protocol/dns.htm for a full
# description of the underlying protocol

# See https://github.com/ruby/ruby/blob/trunk/lib/resolv.rb for the
# Ruby Message implementation that we are using in these tests

describe "Tokaido::DNS::Query.decode" do
  before do
    m = Resolv::DNS::Message.new    
    m.qr = 0 # query
    m.opcode = 0 # standard query
    m.rd = 1 # recursion desired
    m.add_question "foo.tok", Resolv::DNS::Resource::IN::A

    @query = Tokaido::DNS::Query.decode(m.encode)
  end

  it "has a list of queries" do
    @query.questions.length.should == 1
  end

  it "knows the type of each question" do
    question = @query.questions.first
    question.type.should == "A"
  end

  it "knows the domain of each question" do
    question = @query.questions.first
    question.name.should == "foo.tok"
  end

  it "knows how to prepare a response to a query" do
    message = @query.respond do |question, response|
      question.type.should == "A"
      question.name.should == "foo.tok"

      response.data = "127.0.0.1"
      response.ttl = 60
    end

    message.qr.should == 1 # response
    message.opcode.should == 0 # same as request
    message.aa.should == 1 # authoritative
    message.rd.should == 1 # same as request
    message.ra.should == 0 # recursion not available
    message.rcode.should == 0 # no error

    message.answer.size.should == 1

    message.answer.each do |answer|
      name, ttl, data = answer

      name.should == Resolv::DNS::Name.create("foo.tok.")
      ttl.should == 60
      data.should == Resolv::DNS::Resource::IN::A.new("127.0.0.1")
    end
  end

  it "knows how to punt on a request" do
    message = @query.respond do |question, response|
      response.not_found!
    end

    message.qr.should == 1 # response
    message.opcode.should == 0 # same as request
    message.aa.should == 1 # authoritative
    message.rd.should == 1 # same as request
    message.ra.should == 0 # recursion not available
    message.rcode.should == 3 # name error

    message.answer.size.should == 0
  end
end
