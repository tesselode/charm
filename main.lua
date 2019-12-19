local charm = require 'charm'

local beanMan = love.graphics.newImage 'bean man.png'

local layout = charm.new()

function love.draw()
	layout
		:new 'rectangle'
			:beginChildren()
				:new('image', beanMan, 50, 100)
					:scale(1/6)
			:endChildren()
			:expand()
			:centerX(love.graphics.getWidth() / 2)
			:centerY(love.graphics.getHeight() / 2)
			:outlineColor(1, 1, 1)
		:draw()
end
