local charm = require 'charm'

local layout = charm.new()

function love.draw()
	layout
		:new('points', 50, 50, 100, 50, 200, 300, 50, 400)
		:width(500)
		:height(1000)
		:centerX(love.graphics.getWidth() / 2)
		:centerY(love.graphics.getHeight() / 2)
		:draw()
end
