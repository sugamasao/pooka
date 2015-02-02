module SimpleDaemon
  # Daemon run before/after callback class
  class CallbackController
    def initialize
      @before_callback = []
      @after_callback = []
    end

    def add_before_callback(proc)
      @before_callback << proc
    end

    def add_after_callback(proc)
      @after_callback << proc
    end

    def fire_before_callback
      @before_callback.each do |callback|
        callback.call
      end
    end

    def fire_after_callback
      @after_callback.reverse.each do |callback|
        callback.call
      end
    end
  end
end
