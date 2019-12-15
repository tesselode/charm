local charm = require 'charm'

local layout = charm.new()

function love.draw()
	layout
		:new('rectangle', 50, 50, 100, 150)
			:fillColor(.5, .5, .5)
		:new('rectangle', 200, 200, 300, 50)
			if love.keyboard.isDown 'space' then
				layout:outlineColor(1, 0, 0)
			end
		layout:draw()

	love.graphics.print(string.format('Memory usage: %ikb', collectgarbage 'count'))
end
