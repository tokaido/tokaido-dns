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
    end
  end
end
