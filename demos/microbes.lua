local charm = require 'charm'

local ui = charm.new()

local labelFont = love.graphics.newFont(24)

function love.draw()
	ui
		:new 'rectangle'
			:name 'container'
			:beginChildren()
			for i = 1, 5 do
				ui:new('ellipse', nil, nil, 32, 32)
					:center(300 + 150 * math.sin(love.timer.getTime() * (1 + i/10)))
					:middle(300 + 150 * math.cos(love.timer.getTime() * (1 + i/11)))
					:set('outlineColor', 1, 1, 1)
			end
			ui:endChildren()
			:wrap()
			:set('outlineColor', 1, 1, 1)
		:new('text', labelFont, 'Microbes')
			:name 'label'
			:left(ui:getRight 'container' + 64)
			:middle(ui:getY('container', 2/3))
		:draw()
	love.graphics.line(
		ui:getRight 'label', ui:getBottom 'label',
		ui:getLeft 'label', ui:getBottom 'label',
		ui:getRight 'container', ui:getMiddle 'container'
	)
end
