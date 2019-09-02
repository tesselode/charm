local ui = require 'charm'.new()

function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:fillColor(.5, .5, .5)
			:outlineColor(1, 1, 1)
			:outlineWidth(5)
			:cornerRadius(100, 100)
			:cornerSegments(4)
			:beginChildren()
				:new('rectangle', -50, -50, 500, 500)
					:fillColor(1, 0, 0)
			:endChildren()
			:clip()
		:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
