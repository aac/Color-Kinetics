require './power_supply'
require './fixture'
require './color_blast'

include ColorKinetics

ps = PDS150e.new '10.0.115.174'
cb0 = ColorBlast.new(7)
ps.addFixture(cb0)
cb0.set_color(255,255,255)
puts ps.state.inspect()
ps.update()
