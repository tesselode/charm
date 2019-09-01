local ui = require 'charm'.new()

function love.draw()
	ui
		:new('rectangle', love.mouse.getX(), love.mouse.getY(), 150, 100)
			:name 'left'
			:fillColor(.5, .5, .5)
			:beginChildren()
				:new('rectangle', 10, 10, 10, 10)
					:fillColor(1, 0, 0)
					:beginChildren()
						:new('rectangle', 10, 10, 10, 10)
							:fillColor(0, 1, 0)
					:endChildren()
				:new('rectangle', 50, 50, 25, 25)
					:fillColor(0, 0, 1)
			:endChildren()
	ui:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
