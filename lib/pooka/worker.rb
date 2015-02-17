module Pooka
  class Worker
    def run(c, logger)
      until @stop do
        logger.info 'hi'
        sleeping c.sleep_time
      end
    end


    # daemon sleep
    # @param [Fixnum] sec seep seconds
    def sleeping(sec)
      sec.to_i.times do
        break if @stop
        sleep 1
      end
    end

    def stop
      @stop = true
    end
  end
end
