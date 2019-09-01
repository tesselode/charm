local ui = require 'charm'.new()

function love.draw()
	ui:new('rectangle', 50, 50, 100, 150)
		:fillColor(.5, .5, .5)
		:clip()
		:beginChildren()
			:new('rectangle', 50, 50, 200, 50)
				:name 'test'
				if ui:isHovered 'test' then
					ui:fillColor(1, .5, .5)
				else
					ui:fillColor(1, 0, 0)
				end
		ui:endChildren()
	ui:draw()
	if ui:isEntered 'test' then print 'entered' end
	if ui:isExited 'test' then print 'exited' end
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
