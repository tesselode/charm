local charm = require 'charm'

local layout = charm.new()

function love.draw()
	layout
		:new('polygon', 50, 50, 100, 50, 200, 300, 50, 400)
		:centerX(love.graphics.getWidth() / 2)
		:centerY(love.graphics.getHeight() / 2)
		:fillColor(1, 0, 0)
		:outlineColor(1, 1, 1)
		:draw()
end
