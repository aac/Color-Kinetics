module ColorKinetics
  class PowerSupply
    attr_reader :state

    def initialize(ip)
      @ip = ip
      @fixtures = []
      clear
    end

    def clear
      @state = [''].pack("@512")
    end

    def addFixture(f)
      @fixtures << f
      f.set_power_supply(self)
    end

    #send command
    def update
      send(@state)
    end

    # def header
    # end

    def padding(count)
      '' # [''].pack("H#{(512-count) * 2}")
    end 

    def int_helper(val)
      val.to_s(16).rjust(2,'0')
    end 

    def send(data, port=1)
      packet = header(port) << data << padding(data.size)
      @socket.send(packet,
                   0, #flags
                   @ip,
                   '6038')
    end

    def set(channels, *args)
      if channels.is_a? Array
      else
        channel = channels-1
        @state[channel...(channel+args.size)]= args.map{|d| int_helper(d)}.pack(args.size.times.collect{'H2'}.join)
      end
      puts @state
    end
  end

  class PDS150e < PowerSupply
    def header(port=1)
        ["0401dc4a0100010100000000#{'00'}000000ffffffff00"].pack('H42')
    end 
  end
end
