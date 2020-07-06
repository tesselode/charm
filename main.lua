local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw(params)
	ui
		:add(
			25, 25, ui:new('aligner', 750, 550, nil, 1)
				:add(50, 50, ui:new('box', 200, 200))
				:add(150, 150, ui:new('box', 25, 25))
		)
		:draw()
	love.graphics.print('Number of children: ' .. #ui._children)
	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'), 0, 16)
end
