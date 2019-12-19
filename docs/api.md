# API

## charm

### Functions

#### `charm.new()`
#### `charm.extend(parent)`

## Layout

### Functions

#### `Layout:getElement(name)`
#### `Layout:get(elementName, propertyName, ...)`
#### `Layout:select(name)`
#### `Layout:add(element)`
#### `Layout:new(elementClass, ...)`
#### `Layout:name(name)`
#### `Layout:beginChildren(name, ...)`
#### `Layout:endChildren(...)`
#### `Layout:draw()`

## Element

### Callbacks

#### `Element:new(x, y, width, height)`
#### `Element:onBeginChildren(...) end`
#### `Element:onAddChild(child)`
#### `Element:onEndChildren(...) end`
#### `Element:drawSelf() end`
#### `Element:stencil() end`
#### `Element:render(ui) end`
#### `Element:draw(stencilValue)`

### Property getters

#### `local x = Element.get:x(origin)`
#### `local x = Element.get:left()`
#### `local x = Element.get:centerX()`
#### `local x = Element.get:right()`
#### `local y = Element.get:y(origin)`
#### `local y = Element.get:top()`
#### `local y = Element.get:centerY()`
#### `local y = Element.get:bottom()`
#### `local width = Element.get:width()`
#### `local height = Element.get:height()`
#### `local width, height = Element.get:size()`
#### `local left, top, right, bottom = Element.get:childrenBounds()`

### Functions

#### `Element:setColor(propertyName, r, g, b, a)`
#### `local isColorSet = Element:isColorSet(color)`
#### `Element:x(x, origin)`
#### `Element:left(x)`
#### `Element:centerX(x)`
#### `Element:right(x)`
#### `Element:y(y, origin)`
#### `Element:top(y)`
#### `Element:centerY(y)`
#### `Element:bottom(y)`
#### `Element:shift(dx, dy)`
#### `Element:width(width)`
#### `Element:height(height)`
#### `Element:size(width, height)`
#### `Element:bounds(left, top, right, bottom)`
#### `Element:clip()`
#### `Element:addChild(child)`
#### `Element:shiftChildren(dx, dy)`
#### `Element:padLeft(padding)`
#### `Element:padTop(padding)`
#### `Element:padRight(padding)`
#### `Element:padBottom(padding)`
#### `Element:padX(padding)`
#### `Element:padY(padding)`
#### `Element:pad(padding)`
#### `Element:expand()`
#### `Element:wrap()`

## Transform

### Callbacks

#### `Transform:new(x, y)`

### Functions

#### `Transform:angle(angle)`
#### `Transform:scaleX(scale)`
#### `Transform:scaleY(scale)`
#### `Transform:scale(scaleX, scaleY)`
#### `Transform:shearX(shear)`
#### `Transform:shearY(shear)`
#### `Transform:shear(shearX, shearY)`

## Shape

### Callbacks

#### `Shape:drawShape(mode)`

### Functions

#### `Shape:fillColor(r, g, b, a)`
#### `Shape:outlineColor(r, g, b, a)`
#### `Shape:outlineWidth(width)`

## Rectangle

### Functions

#### `Rectangle:cornerRadius(radiusX, radiusY)`
#### `Rectangle:cornerSegments(segments)`

## Ellipse

### Functions

#### `Ellipse:segments(segments)`

## Image

### Callbacks

#### `Image:new(image, x, y)`

### Functions

#### `Image:scaleX(scale)`
#### `Image:scaleY(scale)`
#### `Image:scale(scaleX, scaleY)`
#### `Image:color(r, g, b, a)`

## Text

### Callbacks

#### `Text:new(font, text, x, y)`

### Functions

#### `Text:scaleX(scale)`
#### `Text:scaleY(scale)`
#### `Text:scale(scaleX, scaleY)`
#### `Text:color(r, g, b, a)`
#### `Text:shadowColor(r, g, b, a)`
#### `Text:shadowOffsetX(offset)`
#### `Text:shadowOffsetY(offset)`
#### `Text:shadowOffset(offsetX, offsetY)`

## Paragraph

### Callbacks

#### `Paragraph:new(font, text, limit, align, x, y)`

### Functions

#### `Paragraph:scaleX(scale)`
#### `Paragraph:scaleY(scale)`
#### `Paragraph:scale(scaleX, scaleY)`
#### `Paragraph:color(r, g, b, a)`
#### `Paragraph:shadowColor(r, g, b, a)`
#### `Paragraph:shadowOffsetX(offset)`
#### `Paragraph:shadowOffsetY(offset)`
#### `Paragraph:shadowOffset(offsetX, offsetY)`
