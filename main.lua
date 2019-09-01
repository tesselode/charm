local ui = require 'charm'.new()

function love.draw()
	ui
		:new('rectangle', love.mouse.getX(), love.mouse.getY(), 150, 100)
			:name 'left'
			:fillColor(.5, .5, .5)
		:new 'rectangle'
			:size(50, 50)
			:left(ui:getRight 'left')
			:middle(ui:getMiddle 'left')
			:fillColor(1, 0, 0)
	love.graphics.print('Number of elements: ' .. #ui._elements, 0, 16)
	ui:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
