local ui = require 'charm'.new()

function love.draw()
	ui:new('rectangle', 50, 50, 100, 150)
		:name 'rectangle'
	if ui:get 'rectangle.hovered' then
		ui:fillColor(1, 1, 1)
	else
		ui:fillColor(.5, .5, .5)
	end
	ui:new('ellipse', 250, 50, 100, 150)
		:name 'ellipse'
	if ui:get 'ellipse.hovered' then
		ui:fillColor(1, 1, 1)
	else
		ui:fillColor(.5, .5, .5)
	end
	ui:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
