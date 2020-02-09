local charm = require 'charm'

local layout = charm.new()

function love.draw()
	layout
		:new('line', 50, 50, 100, 50, 200, 300, 50, 400)
		:centerX(love.graphics.getWidth() / 2)
		:centerY(love.graphics.getHeight() / 2)
		:color(1, 0, 0)
		:lineWidth(25)
		:beginChildren()
			:new('rectangle', 0, 0, 100, 100)
				:fillColor(1, 1, 0)
		:endChildren()
		:clip()
		:draw()
end
