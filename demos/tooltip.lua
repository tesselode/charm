local charm = require 'charm'

local ui = charm.new()

local bigFont = love.graphics.newFont(32)
local smallFont = love.graphics.newFont(18)

local buttonIdleColor = {1/4, 1/4, 1/4}
local buttonHoveredColor = {1/2, 1/2, 1/2}

function love.draw()
	ui:new 'rectangle'
		:name 'button'
		:beginChildren()
			:new('text', bigFont, 'click me!')
				:center(400):middle(300)
				:set('fillColor', 1, 0, 0)
		:endChildren()
		:wrap(32)
		:set('fillColor', ui:isHovered 'button' and buttonHoveredColor or buttonIdleColor)
	if ui:isHovered 'button' then
		ui:new 'rectangle'
			:beginChildren()
				:new('paragraph', smallFont, 'This button will print a message to the console when you click it.', 300)
			:endChildren()
			:wrap(16)
			:left(love.mouse.getX() + 16)
			:bottom(love.mouse.getY() - 16)
			:set('fillColor', 1/4, 1/4, 1/3)
	end
	ui:draw()
	if ui:isPressed 'button' then
		print 'hi!'
	end
end
