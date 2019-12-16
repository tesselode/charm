local charm = require 'charm'

local layout = charm.new()

function love.draw()
	layout
		:new('rectangle', 400 + 100 * math.sin(love.timer.getTime()), 50, 100, 150)
			:fillColor(.5, .5, .5)
			:beginChildren()
				:new 'rectangle'
					:size(50, 50)
					:center(layout:get('@parent', 'width')/2 + 400 * math.sin(love.timer.getTime()))
					:middle(layout:get('@parent', 'height')/2)
					:outlineColor(1, 0, 0)
					:name 'child'
			:endChildren()
			:clip()
		:draw()

	love.graphics.print(string.format('Memory usage: %ikb', collectgarbage 'count'))
end
