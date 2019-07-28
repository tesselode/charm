local charm = require 'charm'

local ui = charm.new()

local beanMan = love.graphics.newImage 'bean man.png'

local cornerRadius = 128

function love.update(dt)
	local targetCornerRadius = ui:isHovered 'imageContainer' and 4 or 128
	cornerRadius = cornerRadius + (targetCornerRadius - cornerRadius) * 10 * dt
end

function love.draw()
	ui
		:new 'rectangle'
			:name 'imageContainer'
			:beginChildren()
				:new('image', beanMan)
					:set('scale', .5)
					:center(400):middle(300)
					:set('color', 1, 1, 1, ui:isHovered 'imageContainer' and 1 or .5)
			:endChildren()
			:wrap()
			:clip()
			:set('radius', cornerRadius)
		:draw()
end
