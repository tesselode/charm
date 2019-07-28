local charm = require 'charm'

local idleColor = {1/4, 1/4, 1/4}
local hoveredColor = {1/2, 1/2, 1/2}
local idleColor2 = {1/4, 1/8, 1/8}
local hoveredColor2 = {1/2, 1/4, 1/4}
local idleColor3 = {1/8, 1/4, 1/8}
local hoveredColor3 = {1/4, 1/2, 1/4}

local ui = charm.new()

function love.draw()
	ui
		:new 'rectangle'
			:beginChildren()
				:new 'rectangle'
					:clip()
					:name 'inner'
					:width(50):height(50)
					:center(400):middle(300)
					:set('fillColor', ui:isHovered 'inner' and hoveredColor2 or idleColor2)
					:beginChildren()
						:new('rectangle', 25, 25, 200, 50)
							:name 'inner2'
							:set('fillColor', ui:isHovered 'inner2' and hoveredColor3 or idleColor3)
					:endChildren()
			:endChildren()
			:wrap(50)
			:name 'outer'
			:set('fillColor', ui:isHovered 'outer' and hoveredColor or idleColor)
			:set('radius', 20, 100)
			:set('segments', 4)
		:draw()
	if ui:isPressed 'inner' then print 'pressed' end
	if ui:isReleased 'inner' then print 'released' end

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
