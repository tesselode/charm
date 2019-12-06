local charm = require 'charm'

local Button = charm.extend 'rectangle'

function Button:new(name, x, y, width, height)
	-- call the rectangle constructor
	self.__parent.new(self, x, y, width, height)
	-- name the button
	self:name(name)
	--[[
		create a content table which will temporarily hold
		children added from the UI class. later we'll
		wrap them in another rectangle so we can center
		all the children
	]]
	self.content = self.content or {}
end

-- Create a new property that returns the number of times
-- the button's been pressed
function Button.get:timesPressed()
	local state = self.ui:getState()
	return state.timesPressed
end

-- overwrites the default rectangle behavior so children
-- are added to self.content instead of self._children
function Button:onAddChild(child)
	table.insert(self.content, child)
end

function Button:beforeDraw()
	--[[
		the button will track how many times it has been
		pressed. to do this, we will add a new field
		to the element's state.
	]]
	local state = self.ui:getState()
	state.timesPressed = state.timesPressed or 0

	-- create a content container that perfectly
	-- surrounds all the children
	local contentContainer = self.ui:create 'rectangle'
		:transparent()
	for _, child in ipairs(self.content) do
		contentContainer:addChild(child)
	end
	contentContainer:wrap()

	-- if the size hasn't been set yet, automatically pick
	-- a size for the button
	if self:get 'width' == 0 and self:get 'height' == 0 then
		self:width(contentContainer:get 'width' + 32)
		self:height(contentContainer:get 'height' + 32)
	end

	-- position the content container in the center of the
	-- button (note that these positions are relative to 0, 0),
	-- since the container will be added as a child of the button
	contentContainer:center(self:get 'width' / 2)
	contentContainer:middle(self:get 'height' / 2)

	-- add the content container as a child
	-- (addChild bypasses the the overridden onAddChild)
	self:addChild(contentContainer)

	-- set the background color based on the hover state
	if self:get 'hovered' then
		self:fillColor(.5, .5, .5)
	else
		self:fillColor(1/3, 1/3, 1/3)
	end
end

function Button:afterDraw()
	local state = self.ui:getState()
	if self:get 'pressed' then
		state.timesPressed = state.timesPressed + 1
	end
end

local ui = charm.new()
local buttonFont = love.graphics.newFont(24)

function love.draw()
	ui
		:new(Button, 'testButton')
			:center(love.graphics.getWidth()/2)
			:middle(love.graphics.getHeight()/2)
			:beginChildren()
				:new('text', buttonFont, 'Click me!')
			:endChildren()
		:draw()
	if ui:get('testButton', 'pressed') then
		print(ui:get('testButton', 'timesPressed'))
	end
end
