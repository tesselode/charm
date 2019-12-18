local charm = require 'charm'

local beanMan = love.graphics.newImage 'bean man.png'

local FramedBeanMan = charm.extend()

function FramedBeanMan:render(layout)
	layout
		:new 'rectangle'
			:beginChildren()
				:new('image', beanMan)
					:scale(1/8)
			:endChildren()
			:wrap(16)
			:centerX(0):centerY(0)
			:fillColor(1, 1, 1)
end

local layout = charm.new()

function love.draw()
	layout
		:new(FramedBeanMan)
			:centerX(love.graphics.getWidth()/2)
			:centerY(love.graphics.getHeight()/2)
		:draw()
end
