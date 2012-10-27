require "resolv"

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
end
