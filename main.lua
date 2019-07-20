local charm = require 'charm'

local ui = charm.new()

function love.draw()
	ui
		:beginGroup()
			:rectangle(100, 100, 50, 50)
				:fillColor(.5, .5, .5)
			:rectangle(300, 300, 25, 100)
				:fillColor(1, 0, 0)
		:endGroup(16)
			:center(400 + 200 * math.sin(love.timer.getTime()))
			:middle(300)
			:fillColor(.1, .1, .1)
		:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
