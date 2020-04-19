local charm = require 'charm'

local bigFont = love.graphics.newFont(32)
local smallFont = love.graphics.newFont(16)
local loremIpsum = [[
Maxime eos officia ea. Et dicta nostrum ullam culpa nisi. Rerum est ad voluptatum occaecati autem voluptatem eius facere. Sunt ut saepe est. Et eveniet rem fuga reiciendis.
]]
local idleColor = {.25, .25, .25}
local hoveredColor = {.4, .4, .4}
local heldColor = {1/3, 1/3, 1/3}
local ui = charm.new()

local clicked = false

local function onClick()
	clicked = true
end

function love.draw()
	ui
		-- show button
		:new 'rectangle'
			:beginChildren()
				:new('text', bigFont, clicked and 'thanks!' or 'click me!')
			:endChildren()
			:wrap()
			:pad(32)
			:centerX(love.graphics.getWidth() / 2)
			:centerY(love.graphics.getHeight() / 2)
			:fillColor(ui:get('@current', 'held') and heldColor
			        or ui:get('@current', 'hovered') and hoveredColor
					or idleColor)
			:on('click', onClick)
		-- show tooltip if the button is hovered
		if ui:get('@current', 'hovered') then
			ui:new 'rectangle'
				:beginChildren()
					:new('text', smallFont, loremIpsum, 'right', 300)
				:endChildren()
				:wrap()
				:pad(16)
				:fillColor(.1, .1, .1)
				:left(love.mouse.getX() + 32)
				:bottom(love.mouse.getY() - 32)
		end
		ui:draw()
end
