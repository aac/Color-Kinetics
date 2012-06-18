require 'socket'
module ColorKinetics
  module Fixture
    def initialize(*args)
      @socket = UDPSocket.new
    end

    def header(port=1)
      ["0401dc4a0100#{@fixture_type}00000000ffffffff#{port.to_s(16).rjust(2,'0')}98000000020000"].pack('H48')
    end

    def int_helper(val)
      val.to_s(16).rjust(2,'0')
    end 


    def padding(count)
      [''].pack("H#{(512-count) * 2}")
    end 

    def send(data, port=1)
      packet = header(port) << data << padding(data.size)
      # puts "packet: #{packet.inspect}"
      @socket.send(packet,
                  0, #flags
                  @ip,
                  '6038')
    end

    # data 0-255
    def set(channel, data, port=1)
      if channel.is_a? Array
        if data.is_a? Array
	  d = data.map{|d| int_helper(d)}.pack(channel.map{|c| "@#{c}H2"}.join+"@512")
	  send(d, port)
        else
        end
      else 
      	channel = channel - 1
        send([int_helper(data)].pack("@#{channel}H2@512"), port)        
      end
    end

    lambda {
      i = 1
      rgb = [0,0,0]

      self.send(:define_method, :cycle_color) do
        set_color(*rgb)
	rgb[i] = rgb[i] + 1
	if rgb[i] == 255
	   i = (i+1) % 3
	end
	rgb[(i-1) % 3] = 255 - rgb[i]
	rgb
      end
    }.call
  end

  #72 sets of 3 color leds = 216 channels
  class Tile
    include Fixture
    def initialize
      super
      @fixture_type = "0801"
      @ip = '10.31.66.202'
    end

    #expects ints
    def set_color(r,g,b)
      color = ["#{int_helper(r)}#{int_helper(g)}#{int_helper(b)}"].pack('H6')
      throw :bad_size unless color.size == 3
      channels = ''
      72.times{channels << color}
      send(channels, 1)
      send(channels, 2)
    end	

    def clear
      set_color(0,0,0)
    end
  end
  
  class Blast
    include Fixture
    def initialize(base_channel)
      super
      @fixture_type = "0101"
      @base_channel = base_channel
      @ip = '10.0.115.174'
    end

    def set_color(r,g,b)
      set([@base_channel, @base_channel+1, @base_channel+2],
      	  [r,g,b])
    end
    def clear
      set_color(0,0,0)
    end
  end
end
