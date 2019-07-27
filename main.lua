local charm = require 'charm'

local idleColor = {1/4, 1/4, 1/4}
local hoveredColor = {1/2, 1/2, 1/2}

local ui = charm.new()

function love.draw()
	ui
		:new 'rectangle'
			:beginChildren()
				:new 'rectangle'
					:name 'inner'
					:width(50):height(50)
					:center(400):middle(300)
					:set('fillColor', ui:isHovered 'inner' and hoveredColor or idleColor)
			:endChildren()
			:wrap(50)
			:name 'outer'
			:set('fillColor', ui:isHovered 'outer' and hoveredColor or idleColor)
			:beginChildren()
				:new('rectangle', 75, 75, 200, 50)
					:name 'inner2'
					:set('fillColor', ui:isHovered 'inner2' and hoveredColor or idleColor)
			:endChildren()
		:draw()
	if ui:isEntered 'outer' then print 'entered' end
	if ui:isExited 'outer' then print 'exited' end

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
