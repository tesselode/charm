local ui = require 'charm'.new()

function love.draw()
	ui:new('rectangle', 50, 50, 100, 150)
	if love.keyboard.isDown 'space' then
		ui:fillColor(1, 0, 0)
	end
	love.graphics.print('Number of elements: ' .. #ui._elements, 0, 16)
	ui:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
