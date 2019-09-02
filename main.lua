local ui = require 'charm'.new()

function love.draw()
	ui
		:new 'rectangle'
			:beginChildren()
				:new('rectangle', 50, 50, 50, 50)
					:fillColor(1, 1, 1)
				:new('rectangle', 200, 200, 50, 50)
					:fillColor(1, 1, 1)
			:endChildren()
			:wrap(16)
			:fillColor(.5, .5, .5)
		:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
