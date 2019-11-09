local charm = require 'charm'

local ui = charm.new()

local beanMan = love.graphics.newImage 'bean man.png'

local cornerRadius = 128

function love.update(dt)
	local targetCornerRadius = ui:getElement 'image' and ui:get('image', 'hovered') and 4 or 128
	cornerRadius = cornerRadius + (targetCornerRadius - cornerRadius) * 10 * dt
end

function love.draw()
	ui
		:new 'rectangle'
			:beginChildren()
				:new('image', beanMan)
					:name 'image'
					:scale(.5)
					:center(400):middle(300)
					:color(1, 1, 1, ui:get('image', 'hovered') and 1 or .5)
			:endChildren()
			:wrap()
			:clip()
			:cornerRadius(cornerRadius)
		:draw()
end
