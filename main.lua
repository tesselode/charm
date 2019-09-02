local ui = require 'charm'.new()

local font = love.graphics.newFont(24)
local loremIpsum = [[
Est voluptatem numquam est eos sit recusandae. Et minus at est. Dolorem aut velit sit voluptatibus vitae repudiandae. Quibusdam esse cum culpa et totam. Modi perferendis inventore at laboriosam consequatur harum.
]]

function love.draw()
	ui
		:new('paragraph', font, loremIpsum, 500, 'right', 50, 50)
			:scale(2/3, 2/3)
			:color(1, 1, 1, .5)
		:new 'rectangle'
			:size(25, 25)
			:left(ui:get '@previous.right')
			:middle(ui:get '@previous.middle')
			:fillColor(.5, .5, .5)
		:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
