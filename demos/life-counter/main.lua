local charm = require 'charm'

local numLives = 5
local font = love.graphics.newFont(32)
local ui = charm.new()

function love.draw()
	ui
		:new('text', font, 'LIVES')
			:centerX(love.graphics.getWidth() / 2)
			:bottom(love.graphics.getHeight() - 10)
		:new 'element'
			:beginChildren()
				for i = 1, numLives do
					ui:new 'ellipse'
						:left(i > 1 and ui:get('@previous', 'right') + 10 or 0)
						:size(25, 25)
						:fillColor(1, 1, 1)
				end
			ui:endChildren()
			:wrap()
			:centerX(love.graphics.getWidth() / 2)
			:bottom(ui:get('@previous', 'top') - 5)
		:draw()
end
