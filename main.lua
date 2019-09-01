local ui = require 'charm'.new()

function love.draw()
	ui
		:new('rectangle', love.mouse.getX(), love.mouse.getY(), 150, 100)
			:name 'left'
			:fillColor(.5, .5, .5)
			:clip()
			:beginChildren()
				:new('rectangle', 10, 10, 300, 300)
					:fillColor(1, 0, 0)
					:clip()
					:beginChildren()
						:new('rectangle', -10, 10, 300, 300)
							:fillColor(0, 1, 0)
					:endChildren()
			:endChildren()
	ui:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
