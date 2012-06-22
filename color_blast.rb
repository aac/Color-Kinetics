module ColorKinetics
  class ColorBlast
    include Fixture
    def initalize(base_channel)
      super
    end

    def set_power_supply(ps)
      @power_supply = ps
    end

    def set_color(r,g,b)
      @power_supply.set(@base_channel, r, g, b)
    end
  end
end
