local charm = {}

unpack = unpack or table.unpack -- luacheck: ignore

local function shallowClear(t)
	for k in pairs(t) do t[k] = nil end
end

local function deepClear(t)
	for k, v in pairs(t) do
		if type(v) == 'table' then
			deepClear(v)
		else
			t[k] = nil
		end
	end
end

local function numberOfLines(s)
	local _, newlines = s:gsub('\n', '\n')
	return newlines + 1
end

local function getTextHeight(font, text)
	return font:getHeight() * font:getLineHeight() * numberOfLines(text)
end

-- todo: investigate ways to make this function more memory-efficient
local function getParagraphHeight(font, text, limit)
	local _, lines = font:getWrap(text, limit)
	return #lines * font:getHeight() * font:getLineHeight()
end

local Element = {}

Element.rectangle = {
	new = function(self, x, y, w, h)
		self.x = x or 0
		self.y = y or 0
		self.w = w or 0
		self.h = h or 0
	end,
	set = {
		fillColor = function(self, r, g, b, a)
			self.fillColor = self.fillColor or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.fillColor[i] = r[i] end
			else
				self.fillColor[1] = r
				self.fillColor[2] = g
				self.fillColor[3] = b
				self.fillColor[4] = a
			end
		end,
		outlineColor = function(self, r, g, b, a)
			self.outlineColor = self.outlineColor or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.outlineColor[i] = r[i] end
			else
				self.outlineColor[1] = r
				self.outlineColor[2] = g
				self.outlineColor[3] = b
				self.outlineColor[4] = a
			end
		end,
	},
	draw = function(self)
		love.graphics.push 'all'
		if self.fillColor and #self.fillColor > 0 then
			love.graphics.setColor(unpack(self.fillColor))
			love.graphics.rectangle('fill', 0, 0, self.w, self.h)
		end
		if self.outlineColor and #self.outlineColor > 0 then
			love.graphics.setColor(unpack(self.outlineColor))
			love.graphics.setLineWidth(self.lineWidth or 1)
			love.graphics.rectangle('line', 0, 0, self.w, self.h)
		end
		love.graphics.pop()
	end,
}

Element.image = {
	new = function(self, image, x, y)
		self.image = image
		self.x = x or 0
		self.y = y or 0
		self.w = image:getWidth()
		self.h = image:getHeight()
	end,
	set = {
		scaleX = function(self, sx)
			self.w = self.image:getWidth() * sx
		end,
		scaleY = function(self, sy)
			self.h = self.image:getHeight() * sy
		end,
		scale = function(self, sx, sy)
			self.w = self.image:getWidth() * sx
			self.h = self.image:getHeight() * sy
		end,
		color = function(self, r, g, b, a)
			self.color = self.color or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.color[i] = r[i] end
			else
				self.color[1] = r
				self.color[2] = g
				self.color[3] = b
				self.color[4] = a
			end
		end,
	},
	draw = function(self)
		love.graphics.push 'all'
		if self.color and #self.color > 0 then
			love.graphics.setColor(unpack(self.color))
		end
		local sx = self.w / self.image:getWidth()
		local sy = self.h / self.image:getHeight()
		love.graphics.draw(self.image, 0, 0, 0, sx, sy)
		love.graphics.pop()
	end
}

Element.text = {
	new = function(self, font, text, x, y)
		self.font = font
		self.text = text
		self.x = x or 0
		self.y = y or 0
		self.w = font:getWidth(text)
		self.h = getTextHeight(font, text)
	end,
	set = {
		scaleX = function(self, sx)
			self.w = self.font:getWidth(self.text) * sx
		end,
		scaleY = function(self, sy)
			self.h = getTextHeight(self.font, self.text) * sy
		end,
		scale = function(self, sx, sy)
			self.w = self.font:getWidth(self.text) * sx
			self.h = getTextHeight(self.font, self.text) * sy
		end,
		color = function(self, r, g, b, a)
			self.color = self.color or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.color[i] = r[i] end
			else
				self.color[1] = r
				self.color[2] = g
				self.color[3] = b
				self.color[4] = a
			end
		end,
		shadowColor = function(self, r, g, b, a)
			self.shadowColor = self.shadowColor or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.shadowColor[i] = r[i] end
			else
				self.shadowColor[1] = r
				self.shadowColor[2] = g
				self.shadowColor[3] = b
				self.shadowColor[4] = a
			end
		end,
		shadowOffset = function(self, offsetX, offsetY)
			self.shadowOffsetX = offsetX or 0
			self.shadowOffsetY = offsetY or 0
		end,
	},
	draw = function(self)
		love.graphics.push 'all'
		love.graphics.setFont(self.font)
		local sx = self.w / self.font:getWidth(self.text)
		local sy = self.h / getTextHeight(self.font, self.text)
		if self.shadowColor and #self.shadowColor > 0 then
			local offsetX = self.shadowOffsetX or 1
			local offsetY = self.shadowOffsetY or 1
			love.graphics.setColor(unpack(self.shadowColor))
			love.graphics.print(self.text, offsetX, offsetY, 0, sx, sy)
		end
		love.graphics.setColor(1, 1, 1)
		if self.color and #self.color > 0 then
			love.graphics.setColor(unpack(self.color))
		end
		love.graphics.print(self.text, 0, 0, 0, sx, sy)
		love.graphics.pop()
	end,
}

Element.paragraph = {
	new = function(self, font, text, limit, align, x, y)
		self.font = font
		self.text = text
		self.limit = limit
		self.align = align
		self.x = x or 0
		self.y = y or 0
		self.w = limit
		self.h = getParagraphHeight(font, text, limit)
	end,
	set = {
		scaleX = function(self, sx)
			self.w = self.limit * sx
		end,
		scaleY = function(self, sy)
			self.h = getParagraphHeight(self.font, self.text, self.limit) * sy
		end,
		scale = function(self, sx, sy)
			self.w = self.limit * sx
			self.h = getParagraphHeight(self.font, self.text, self.limit) * sy
		end,
		color = function(self, r, g, b, a)
			self.color = self.color or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.color[i] = r[i] end
			else
				self.color[1] = r
				self.color[2] = g
				self.color[3] = b
				self.color[4] = a
			end
		end,
		shadowColor = function(self, r, g, b, a)
			self.shadowColor = self.shadowColor or {}
			if type(r) == 'table' then
				for i = 1, 4 do self.shadowColor[i] = r[i] end
			else
				self.shadowColor[1] = r
				self.shadowColor[2] = g
				self.shadowColor[3] = b
				self.shadowColor[4] = a
			end
		end,
		shadowOffset = function(self, offsetX, offsetY)
			self.shadowOffsetX = offsetX or 0
			self.shadowOffsetY = offsetY or 0
		end,
	},
	draw = function(self)
		love.graphics.push 'all'
		love.graphics.setFont(self.font)
		local sx = self.w / self.limit
		local sy = self.h / getParagraphHeight(self.font, self.text, self.limit)
		if self.shadowColor and #self.shadowColor > 0 then
			local offsetX = self.shadowOffsetX or 1
			local offsetY = self.shadowOffsetY or 1
			love.graphics.setColor(unpack(self.shadowColor))
			love.graphics.printf(self.text, offsetX, offsetY, self.limit, self.align, 0, sx, sy)
		end
		love.graphics.setColor(1, 1, 1)
		if self.color and #self.color > 0 then
			love.graphics.setColor(unpack(self.color))
		end
		love.graphics.printf(self.text, 0, 0, self.limit, self.align, 0, sx, sy)
		love.graphics.pop()
	end,
}

local Ui = {}
Ui.__index = Ui

function Ui:_getElement(name)
	if name == '@current' then
		return self._elements[self._activeElements]
	end
	if name == '@previous' then
		return self._elements[self._activeElements - 1]
	end
	for i = self._activeElements, 1, -1 do
		local element = self._elements[i]
		if element.name == name then
			return element
		end
	end
end

function Ui:_getCurrentElement()
	return self._elements[self._activeElements]
end

function Ui:_getElementClass(element)
	if type(element.type) == 'string' then
		return Element[element.type]
	end
	return element.type
end

function Ui:_getNewElement()
	self._activeElements = self._activeElements + 1
	local element
	if self._elements[self._activeElements] then
		element = self._elements[self._activeElements]
		deepClear(element)
	else
		element = {}
		table.insert(self._elements, element)
	end
	if self._currentGroup > 0 then
		self._groupQueue[self._currentGroup] = self._groupQueue[self._currentGroup] or {}
		table.insert(self._groupQueue[self._currentGroup], element)
	end
	return element
end

function Ui:new(type, ...)
	local element = self:_getNewElement()
	element.type = type
	local elementClass = self:_getElementClass(element)
	elementClass.new(element, ...)
	return self
end

function Ui:getX(name, anchor)
	anchor = anchor or 0
	local element = self:_getElement(name)
	return element.x + element.w * anchor
end

function Ui:getLeft(name) return self:getX(name, 0) end
function Ui:getCenter(name) return self:getX(name, .5) end
function Ui:getRight(name) return self:getX(name, 1) end

function Ui:getY(name, anchor)
	anchor = anchor or 0
	local element = self:_getElement(name)
	return element.y + element.h * anchor
end

function Ui:getTop(name) return self:getY(name, 0) end
function Ui:getMiddle(name) return self:getY(name, .5) end
function Ui:getBottom(name) return self:getY(name, 1) end

function Ui:getWidth(name) return self:_getElement(name).w end
function Ui:getHeight(name) return self:_getElement(name).h end
function Ui:getSize(name) return self:getWidth(name), self:getHeight(name) end

function Ui:x(x, anchor)
	anchor = anchor or 0
	local element = self:_getCurrentElement()
	element.x = x - element.w * anchor
	return self
end

function Ui:left(x) return self:x(x, 0) end
function Ui:center(x) return self:x(x, .5) end
function Ui:right(x) return self:x(x, 1) end

function Ui:y(y, anchor)
	anchor = anchor or 0
	local element = self:_getCurrentElement()
	element.y = y - element.h * anchor
	return self
end

function Ui:top(y) return self:y(y, 0) end
function Ui:middle(y) return self:y(y, .5) end
function Ui:bottom(y) return self:y(y, 1) end

function Ui:width(width)
	local element = self:_getCurrentElement()
	element.w = width
	return self
end

function Ui:height(height)
	local element = self:_getCurrentElement()
	element.h = height
	return self
end

function Ui:size(width, height)
	width, height = width or 0, height or 0
	self:width(width)
	self:height(height)
	return self
end

function Ui:name(name)
	local element = self:_getCurrentElement()
	element.name = name
	return self
end

function Ui:set(property, ...)
	local element = self:_getCurrentElement()
	local elementClass = self:_getElementClass(element)
	if elementClass.set and elementClass.set[property] then
		elementClass.set[property](element, ...)
	else
		element[property] = select(1, ...)
	end
	return self
end

function Ui:clip()
	local element = self:_getCurrentElement()
	element.clip = true
	return self
end

function Ui:beginGroup()
	self._currentGroup = self._currentGroup + 1
	return self
end

function Ui:endGroup()
	local queue = self._groupQueue[self._currentGroup]
	self._currentGroup = self._currentGroup - 1
	-- make a new rectangle
	self:new 'rectangle'
	-- add the grouped elements as children of the rectangle
	for _, element in ipairs(queue) do
		element.parentIndex = self._activeElements
	end
	-- clear the group queue
	shallowClear(queue)
	return self
end

function Ui:wrap(padding)
	padding = padding or 0
	local parent = self:_getCurrentElement()
	local parentIndex = self._activeElements
	-- get the bounds of current element's children
	local left, top, right, bottom
	for i = 1, self._activeElements do
		local child = self._elements[i]
		if child.parentIndex == parentIndex then
			left = left and math.min(left, child.x) or child.x
			top = top and math.min(top, child.y) or child.y
			right = right and math.max(right, child.x + child.w) or child.x + child.w
			bottom = bottom and math.max(bottom, child.y + child.h) or child.y + child.h
		end
	end
	-- apply padding
	left = left - padding
	top = top - padding
	right = right + padding
	bottom = bottom + padding
	-- change the parent position and size
	parent.x = left
	parent.y = top
	parent.w = right - left
	parent.h = bottom - top
	-- adjust the children's positions
	for i = 1, self._activeElements do
		local child = self._elements[i]
		if child.parentIndex == parentIndex then
			child.x = child.x - left
			child.y = child.y - top
		end
	end
	return self
end

function Ui:_draw(parentIndex, stencilValue)
	stencilValue = stencilValue or 0
	for i = 1, self._activeElements do
		local element = self._elements[i]
		local elementClass = self:_getElementClass(element)
		if element.parentIndex == parentIndex then
			love.graphics.push 'all'
			love.graphics.translate(element.x, element.y)
			elementClass.draw(element)
			if element.clip then
				stencilValue = stencilValue + 1
				self._stencilFunctionCache[element] = self._stencilFunctionCache[element] or function()
					love.graphics.rectangle('fill', 0, 0, element.w, element.h)
				end
				love.graphics.stencil(self._stencilFunctionCache[element], 'increment', 1, true)
				love.graphics.setStencilTest('gequal', stencilValue)
			end
			self:_draw(i, stencilValue)
			if element.clip then
				stencilValue = stencilValue - 1
				love.graphics.stencil(self._stencilFunctionCache[element], 'decrement', 1, true)
				love.graphics.setStencilTest()
			end
			love.graphics.pop()
		end
	end
end

function Ui:_finish()
	self._activeElements = 0
	while self._currentGroup > 0 do
		shallowClear(self._groupQueue[self._currentGroup])
		self._currentGroup = self._currentGroup - 1
	end
end

function Ui:draw()
	self:_draw()
	self:_finish()
	return self
end

function charm.new()
	return setmetatable({
		_elements = {},
		_activeElements = 0,
		_currentGroup = 0,
		_groupQueue = {},
		_stencilFunctionCache = {},
	}, Ui)
end

return charm
