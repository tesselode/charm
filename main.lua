local ui = require 'charm'.new()

function love.draw()
	ui:new('rectangle', 50, 50, 100, 150)
		:name 'test'
	if ui:isHovered 'test' then
		ui:fillColor(1, 1, 1)
	else
		ui:fillColor(.5, .5, .5)
	end
	ui:draw()
	if ui:isEntered 'test' then print 'entered' end
	if ui:isExited 'test' then print 'exited' end
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
