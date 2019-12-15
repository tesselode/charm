local charm = require 'charm'

local testElement = setmetatable({}, charm.Rectangle)

testElement:x(love.graphics.getWidth()/2, .5)
testElement:y(love.graphics.getHeight()/2, .5)
testElement:size(100, 200)
testElement:fillColor(.5, .5, .5)
testElement:outlineColor(1, 1, 1)
testElement:outlineWidth(4)
testElement:cornerRadius(10)

function love.draw()
	testElement:draw()
end
