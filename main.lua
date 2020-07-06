local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw(params)
	ui
		:add(
			25, 25, ui:new('row', 500, 50)
				:add(ui:new('box', 50, 200))
				:add(ui:new('box', 200, 200))
				:add(ui:new('box', 100, 200))
		)
		:draw()
	love.graphics.print('Number of children: ' .. #ui._children)
	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'), 0, 16)
end
