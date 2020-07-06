local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw(params)
	ui
		:add(
			50, 50, ui:new 'wrapper'
				:add(50, 50, ui:new('box', 200, 200))
				:add(150, 150, ui:new('box', 150, 200))
		)
		:draw()
	love.graphics.print('Number of children: ' .. #ui._children)
	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'), 0, 16)
end
