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
					:outlineColor(1, 1, 1)
			end
			ui:endChildren()
			:wrap(16)
			:outlineColor(1, 1, 1)
		:new('text', labelFont, 'Microbes')
			:name 'label'
			:left(ui:get('container', 'right') + 64)
			:middle(ui:get('container', 'y', 2/3))
		:new 'line'
			:point(ui:get('label', 'right'), ui:get('label', 'bottom'))
			:point(ui:get('label', 'left'), ui:get('label', 'bottom'))
			:point(ui:get('container', 'right'), ui:get('container', 'middle'))
		:draw()
end
