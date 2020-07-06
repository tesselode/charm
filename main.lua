local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw(params)
	ui
		:add(
			25, 25, ui:new('wrapper', 750, 550, nil, 1)
				:pad(75)
				:add(0, 0, ui:new('box', 200, 200))
				:add(150, 150, ui:new('box', 200, 200))
		)
		:draw()
	love.graphics.print('Number of children: ' .. #ui._children)
	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'), 0, 16)
end
