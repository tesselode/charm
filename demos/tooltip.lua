local charm = require 'charm'

local ui = charm.new()

local bigFont = love.graphics.newFont(32)
local smallFont = love.graphics.newFont(18)

local buttonIdleColor = {1/4, 1/4, 1/4}
local buttonHoveredColor = {1/2, 1/2, 1/2}
local tooltipText = [[
This button will print a message to the console when you left-click it.

You can also drag it using the right mouse button.
]]

local buttonX, buttonY = 400, 300

function love.draw()
	ui:new 'rectangle'
		:name 'button'
		:beginChildren()
			:new('text', bigFont, 'click me!')
				:center(buttonX):middle(buttonY)
				:set('fillColor', 1, 0, 0)
		:endChildren()
		:wrap(32)
		:set('fillColor', ui:isHovered 'button' and buttonHoveredColor or buttonIdleColor)
	if ui:isHovered 'button' then
		ui:new 'rectangle'
			:beginChildren()
				:new('paragraph', smallFont, tooltipText, 300)
			:endChildren()
			:wrap(16)
			:left(love.mouse.getX() + 16)
			:bottom(love.mouse.getY() - 16)
			:set('fillColor', 1/4, 1/4, 1/3)
	end
	ui:draw()
	if ui:isPressed 'button' then print 'hi!' end
	local dragged, dx, dy = ui:isDragged('button', 2)
	if dragged then
		buttonX = buttonX + dx
		buttonY = buttonY + dy
	end
end
