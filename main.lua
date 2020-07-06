local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw(params)
	local parent = ui:new('element', 100, 150)
	parent:add(ui:new('element', 200, 200), 50, 50)
	ui:add(parent, 50, 50)
	ui:draw()
	love.graphics.print('Number of children: ' .. #ui._children)
	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'), 0, 16)
end
