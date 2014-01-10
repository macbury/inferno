require "logger"

module Inferno

  class Logger
    def initialize(notifications)
      @logger  = ::Logger.new(STDOUT)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        msg + "\n"
      end
      notifications.on("triggered.event", self) { |payload| @logger.info "Triggered: #{payload[:event].inspect} with payload: #{payload[:payload].inspect}" }
    end
  end
  
end