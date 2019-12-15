local charm = require 'charm'

local layout = charm.new()

function love.draw()
	layout
		:new('rectangle', 50, 50, 100, 150)
			:fillColor(.5, .5, .5)
			:name 'gray'
		:new 'rectangle'
			:size(300, 50)
			:left(layout:get('gray', 'right'))
			:middle(layout:get('gray', 'middle'))
			:outlineColor(1, 0, 0)
		:draw()

	love.graphics.print(string.format('Memory usage: %ikb', collectgarbage 'count'))
end
