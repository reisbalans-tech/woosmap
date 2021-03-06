# frozen_string_literal: true

require 'logger'

module Woos
  module Map
    module Logger
      attr_accessor :logger

      def log_file=(file)
        self.logger = ::Logger.new(file)
      end

      def self.extended(base)
        base.log_file = RUBY_PLATFORM.index(/mswin(?!ce)|mingw|cygwin|bccwin/) ? 'nul' : '/dev/null'
      end
    end
  end
end
