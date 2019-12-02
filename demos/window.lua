local charm = require 'charm'

local titleFont = love.graphics.newFont(24)
local beanMan = love.graphics.newImage 'bean man.png'

local Window = charm.extend()

function Window:new(name, title, x, y, width, height)
	self:name(name)
	self._title = title
	local state = self:getState()
	state.x = state.x or x
	state.y = state.y or y
	self.__parent.new(self, state.x, state.y, width, height)
end

function Window:onAddChild(element)
	self._content = self._content or {}
	table.insert(self._content, element)
end

function Window:beforeDraw()
	local titlebar = self.ui:create 'rectangle'
		:name(self._name .. '.titlebar')
		:addChild(self.ui:create('text', titleFont, self._title))
		:wrap(4)
		:x(0):y(0)
		:width(self:get 'width')
		:fillColor(.2, .2, .2)
	self:addChild(titlebar)

	local contentContainer = self.ui:create 'rectangle'
		:top(titlebar:get 'bottom')
		:width(self:get 'width')
		:height(self:get 'height' - titlebar:get 'height')
		:fillColor(.1, .1, .1)
		:clip()
	for _, child in ipairs(self._content) do
		contentContainer:addChild(child)
	end
	self:addChild(contentContainer)
end

function Window:afterDraw()
	local state = self:getState()
	local titlebar = self.ui:getElement(self._name .. '.titlebar')
	local dragged, dx, dy = titlebar:get 'dragged'
	if dragged then
		state.x = state.x + dx
		state.y = state.y + dy
	end
end

local ui = charm.new()

function love.draw()
	ui
		:new(Window, 'testWindow', 'test window', 50, 50, 500, 500)
			:beginChildren()
				:new('image', beanMan)
			:endChildren()
		:draw()
end
