local charm = require 'charm'

local ui = charm.new()

function love.draw()
	local t = love.timer.getTime()
	ui:beginGroup()
	for i = 1, 5 do
		ui:new('rectangle', nil, nil, 50, 50)
			:center(400 + 200 * math.sin(t * (1 + i / 10)))
			:middle(300 + 200 * math.cos(t * (1 + i / 12)))
			:set('fillColor', 1, 1, 1)
	end
	ui
		:endGroup(16)
			:center(400)
			:middle(300)
			:set('fillColor', .25, .25, .25)
		:new('rectangle', nil, nil, 50, 50)
			:left(ui:getRight '@previous')
			:middle(ui:getMiddle '@previous')
			:shift(50)
			:set('fillColor', 1, 0, 0)
		:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
