local charm = require 'charm'

local layout = charm.new()

function love.draw()
	layout
		:new('rectangle', 50, 50, 100, 150)
			:fillColor(.5, .5, .5)
		:new 'rectangle'
			:size(300, 50)
			:left(layout:get('@previous', 'right'))
			:middle(layout:get('@previous', 'middle'))
		:draw()

	love.graphics.print(string.format('Memory usage: %ikb', collectgarbage 'count'))
end
