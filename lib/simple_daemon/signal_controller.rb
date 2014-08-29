module SimpleDaemon
  class SignalController

    def initialize
      @int  = false
      @term = false
      @usr1 = false
      @hup  = false
    end

    def signal_set(signal_number)
      signal = signal_number_to_word(signal_number)
      case signal
        when :HUP
          @hup = true
        when :INT
          @int = true
        when :TERM
          @term = true
        when :USR1
          @usr1 = true
        else
          nil
      end
    end

    def signal_release(signal_number)
      signal = signal_number_to_word(signal_number)
      case signal
        when :HUP
          @hup = false
        when :INT
          @int = false
        when :TERM
          @term = false
        when :USR1
          @usr1 = false
        else
          nil
      end
    end

    def hup?
      @hup
    end

    def int?
      @int
    end

    def term?
      @term
    end

    def usr1?
      @usr1
    end

    def received_signal?
      @hup || @int || @term || @usr1
    end

    # Signal number to word(15 -> 'INT')
    # @param [Fixnum] signal_number
    # @return [String] 'INT' etc (no match number is :"")
    def signal_number_to_word(signal_number)
      Array(Signal.list.rassoc(signal_number)).first.to_s.to_sym
    end
  end
end
