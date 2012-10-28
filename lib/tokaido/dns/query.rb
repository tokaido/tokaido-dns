require "resolv"

module Tokaido
  module DNS
    class Question
      def initialize(raw_question)
        @raw_question = raw_question
      end

      def type
        TYPES[@raw_question[1]]
      end

      def name
        @raw_question[0].to_s
      end

      def response_name
        @raw_question[0]
      end

      def response_class
        @raw_question[1]
      end
    end

    class Answer
      attr_writer :data, :ttl

      def initialize
        @not_found = false
      end

      def not_found!
        @not_found = true
      end

      def not_found?
        @not_found
      end

      def add_to_response(question, response)
        response.add_answer question.response_name, @ttl, question.response_class.new(*@data)
      end
    end

    class Query
      def self.decode(data)
        message = Resolv::DNS::Message.decode(data)
        new(message)
      end

      def initialize(message)
        @message = message
      end

      def questions
        @questions ||= @message.question.map { |m| Question.new(m) }
      end

      def respond
        response = Resolv::DNS::Message.new @message.id
        response.qr = 1 # response
        response.opcode = @message.opcode # same as request
        response.aa = 1 # authoritative
        response.rd = @message.rd # recursion desired same as request
        response.ra = 0 # does not support recursion

        not_found = false

        answers = questions.map do |question|
          answer = Answer.new.tap { |a| yield question, a }
          not_found = true if answer.not_found?
          [ question, answer ]
        end

        if not_found
          response.rcode = 3 # name error
        else
          response.rcode = 0 # no error

          answers.each do |question, answer|
            answer.add_to_response(question, response)
          end
        end

        response
      end
    end
  end
end
