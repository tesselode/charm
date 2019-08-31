local charm = {}

local function newElementClass(parent)
	local class = setmetatable({}, parent)
	class.__index = class
	return class
end

local Element = {}

Element.base = newElementClass()

function Element.base:new(x, y, width, height)
	self.x = x or 0
	self.y = y or 0
	self.width = width or 0
	self.height = height or 0
end

Element.rectangle = newElementClass(Element.base)

Element.rectangle.set = {}

function Element.rectangle.set:fillColor(r, g, b, a)
	self.fillColor = self.fillColor or {}
	if type(r) == 'table' then
		for i = 1, 4 do self.fillColor[i] = r[i] end
	else
		self.fillColor[1] = r
		self.fillColor[2] = g
		self.fillColor[3] = b
		self.fillColor[4] = a
	end
end

function Element.rectangle:draw()
	love.graphics.push 'all'
	if self.fillColor and #self.fillColor > 1 then
		love.graphics.setColor(self.fillColor)
		love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
	end
	love.graphics.pop()
end

local Ui = {}

function Ui:__index(k)
	if Ui[k] then return Ui[k] end
	self._propertyCache[k] = self._propertyCache[k] or function(_, ...)
		return self:set(k, ...)
	end
	return self._propertyCache[k]
end

function Ui:_getElementClass(className)
	if type(className) == 'table' then return className end
	return Element[className]
end

function Ui:select(element)
	self._selectedElement = element
end

function Ui:_clearElement(element)
	for key, value in pairs(element) do
		if type(value) == 'table' then
			for nestedKey in pairs(value) do
				value[nestedKey] = nil
			end
		else
			element[key] = nil
		end
	end
end

function Ui:new(className, ...)
	local element
	for _, e in ipairs(self._elementPool) do
		if not e._used then
			self:_clearElement(e)
			element = e
			break
		end
	end
	if not element then
		element = {}
		table.insert(self._elementPool, element)
	end
	element._used = true
	setmetatable(element, self:_getElementClass(className))
	if element.new then element:new(...) end
	table.insert(self._elements, element)
	self:select(element)
	return self
end

function Ui:set(property, ...)
	local element = self._selectedElement
	if element.set and element.set[property] then
		element.set[property](element, ...)
	end
	return self
end

function Ui:_draw()
	for _, element in ipairs(self._elements) do
		if element.draw then element:draw() end
	end
end

function Ui:_finish()
	for i = #self._elements, 1, -1 do
		self._elements[i] = nil
	end
	for _, element in ipairs(self._elementPool) do
		element._used = false
	end
end

function Ui:draw()
	self:_draw()
	self:_finish()
end

function charm.new()
	return setmetatable({
		_elements = {},
		_elementPool = {},
		_selectedElement = nil,
		_propertyCache = {},
	}, Ui)
end

return charm
