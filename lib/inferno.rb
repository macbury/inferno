require "inferno/version"
require "inferno/logger"
require "eventmachine"

module Inferno
  class Event
    def initialize
      @events  = {}
      @fibers  = []
    end

    def fibers
      @fibers
    end

    def events
      @events.keys
    end

    # Just like on, but causes the bound callback to only fire once before being removed. 
    # Handy for saying "the next time that X happens, do this".
    # @param [String] [event name]
    # @param [Object] [on what object run callback]
    # @param [Proc] [callback]
    def once(event, context, &callback)
      on(event, context, &callback)
      on(event, self) { off(event) }
    end

    # Bind a callback function to an object. The callback will be invoked whenever the event is fired.
    # @param [String] [event name]
    # @param [Object] [on what object run callback]
    # @param [Proc] [callback with proc]
    def on(event, context, &callback)
      @events[event] ||= {}
      @events[event][context] = callback
    end

    def count(event)
      @events[event] ? @events[event].size : 0
    end

    # Remove a previously-bound callback function from an object. 
    # If no context is specified, all of the versions of the callback with different contexts will be removed. 
    # If no event is specified, callbacks for all events will be removed.
    # @param [String] [event name]
    # @param [Object] [on what object run callback]
    def off(event,context=nil)
      if @events[event]
        if context
          @events[event].delete(context) 
        else
          @events[event].clear
        end
        @events.delete(event) if @events[event].empty?
      end
    end

    # Trigger callbacks for the given event, or space-delimited list of events. Subsequent arguments to trigger will be passed along to the event callbacks.
    # @param [String] [event name]
    # @param [Hash] [payload to send]
    def trigger(event, payload={})
      broadcast(false, "triggered.event", { event: event, payload: payload })
      broadcast(true,  event, payload)
    end

    private

      def pool_fiber
        @fibers << Fiber.new { |block| loop { block = fiber_loop(block) } } if @fibers.empty?
        @fibers.shift
      end

      def in_fiber(&block)
        pool_fiber.resume(block)
      end

      def fiber_loop(block)
        block.call
        @fibers.unshift Fiber.current
        Fiber.yield
      end

      # Run block in fiber and next reactor tick
      # @param [Proc] [Block to run in next tick if eventmachine reactor is running]
      def schedule(&block)
        fiber = pool_fiber
        if defined?(EM) && EM.reactor_running?
          EM.next_tick { fiber.resume(block) }
        else
          fiber.resume(block)
        end
      end

      def broadcast(in_fiber, event, payload={})
        list = @events[event] || []

        list.each do |context, block| 
          if in_fiber
            schedule { run_in_context(context, payload, &block) }
          else
            run_in_context(context, payload, &block)
          end
        end
      end

      def run_in_context(context, payload, &block)
        context.instance_exec(payload, &block)
      end
  end
end
