local ui = require 'charm'.new()

function love.draw()
	ui:new('rectangle', 50, 50, 100, 150)
		:fillColor(.5, .5, .5)
		:clip()
		:beginChildren()
			:new('rectangle', 50, 50, 200, 50)
				:name 'test'
				if ui:isHeld 'test' then
					ui:fillColor(1, 1, 1)
				elseif ui:isHovered 'test' then
					ui:fillColor(1, .5, .5)
				else
					ui:fillColor(1, 0, 0)
				end
		ui:endChildren()
	ui:draw()
	if ui:isEntered 'test' then print 'entered' end
	if ui:isExited 'test' then print 'exited' end
	if ui:isPressed 'test' then print 'pressed' end
	if ui:isReleased 'test' then print 'released' end
	local dragged, dx, dy = ui:isDragged 'test'
	if dragged then
		print('dragged', dx, dy)
	end
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
