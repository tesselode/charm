local charm = require 'charm'

local layout = charm.new()

function love.draw()
	layout
		:new('rectangle', 400 + 100 * math.sin(love.timer.getTime()), 50, 100, 150)
			:fillColor(.5, .5, .5)
			:beginChildren()
				:new 'rectangle'
					:size(50, 50)
					:right(layout:get('@parent', 'width'))
					:bottom(layout:get('@parent', 'height'))
					:outlineColor(1, 0, 0)
					:name 'child'
			:endChildren()
		print(layout:get('child', 'right'))
		layout:draw()

	love.graphics.print(string.format('Memory usage: %ikb', collectgarbage 'count'))
end
