Charm <!-- omit in toc -->
=====
Charm is a library for LÖVE that makes it easier to arrange and draw graphics, such as shapes, images, and text. It excels at relative positioning, which can become cumbersome as a layout gets more complex. It also handles mouse events, so it can be used for basic UI tasks, like creating buttons.

This library is similar to [Boxer](https://github.com/tesselode/boxer), but it's **immediate mode**, which means that instead of creating objects that represent each graphic you want to draw, you simply tell Charm what you want to draw on each frame.

Table of contents <!-- omit in toc -->
-----------------
- [Installation](#installation)
- [API](#api)
  - [Base](#base)
    - [Properties](#properties)
      - [`Base.get` (table)](#baseget-table)
      - [`Base.preserve` (table)](#basepreserve-table)
    - [Functions](#functions)
      - [`Base:afterDraw()`](#baseafterdraw)
      - [`Base:beforeDraw()`](#basebeforedraw)
      - [`Base:bottom(y)`](#basebottomy)
      - [`Base:center(x)`](#basecenterx)
      - [`Base:clip()`](#baseclip)
      - [`local containsPoint = Base:containsPoint(x, y)`](#local-containspoint--basecontainspointx-y)
      - [`Base:drawSelf()`](#basedrawself)
      - [`local bottom = Base.get:bottom()`](#local-bottom--basegetbottom)
      - [`local center = Base.get:center()`](#local-center--basegetcenter)
      - [`local dragged = Base.get:dragged(button)`](#local-dragged--basegetdraggedbutton)
      - [`local entered = Base.get:entered()`](#local-entered--basegetentered)
      - [`local exited = Base.get:exited()`](#local-exited--basegetexited)
      - [`local height = Base.get:height()`](#local-height--basegetheight)
      - [`local held = Base.get:held(button)`](#local-held--basegetheldbutton)
      - [`local hovered = Base.get:hovered()`](#local-hovered--basegethovered)
      - [`local left = Base.get:left()`](#local-left--basegetleft)
      - [`local middle = Base.get:middle()`](#local-middle--basegetmiddle)
      - [`local pressed = Base.get:pressed(button)`](#local-pressed--basegetpressedbutton)
      - [`local released = Base.get:released(button)`](#local-released--basegetreleasedbutton)
      - [`local right = Base.get:right()`](#local-right--basegetright)
      - [`local width, height = Base.get:size()`](#local-width-height--basegetsize)
      - [`local top = Base.get:top()`](#local-top--basegettop)
      - [`local width = Base.get:width()`](#local-width--basegetwidth)
      - [`local x = Base.get:x(anchor)`](#local-x--basegetxanchor)
      - [`local y = Base.get:y(anchor)`](#local-y--basegetyanchor)
      - [`local z = Base.get:z()`](#local-z--basegetz)
      - [`local state = Base:getState()`](#local-state--basegetstate)
      - [`Base:height(height)`](#baseheightheight)
      - [`Base:left(x)`](#baseleftx)
      - [`Base:middle(y)`](#basemiddley)
      - [`Base:name(name)`](#basenamename)
      - [`Base:new(...)`](#basenew)
      - [`Base:onAddChild(element)`](#baseonaddchildelement)
      - [`Base:opaque()`](#baseopaque)
      - [`Base:right(x)`](#baserightx)
      - [`Base:size(width)`](#basesizewidth)
      - [`Base:shift(dx, dy)`](#baseshiftdx-dy)
      - [`Base:stencil()`](#basestencil)
      - [`Base:top(y)`](#basetopy)
      - [`Base:transparent()`](#basetransparent)
      - [`Base:width(width)`](#basewidthwidth)
      - [`Base:wrap(padding)`](#basewrappadding)
      - [`Base:x(x, anchor)`](#basexx-anchor)
      - [`Base:y(y, anchor)`](#baseyy-anchor)
      - [`Base:z(z)`](#basezz)
  - [charm](#charm)
    - [Functions](#functions-1)
      - [`local ElementClass = charm.extend(parent)`](#local-elementclass--charmextendparent)
      - [`local ui = charm.new()`](#local-ui--charmnew)
  - [Ellipse](#ellipse)
    - [Functions](#functions-2)
      - [`Ellipse:fillColor(r, g, b, a)`](#ellipsefillcolorr-g-b-a)
      - [`Ellipse:new(x, y, width, height)`](#ellipsenewx-y-width-height)
      - [`Ellipse:outlineColor(r, g, b, a)`](#ellipseoutlinecolorr-g-b-a)
      - [`Ellipse:outlineWidth(width)`](#ellipseoutlinewidthwidth)
      - [`Ellipse:segments(segments)`](#ellipsesegmentssegments)
  - [Image](#image)
    - [Functions](#functions-3)
      - [`Image:color(r, g, b, a)`](#imagecolorr-g-b-a)
      - [`Image:new(image, x, y)`](#imagenewimage-x-y)
      - [`Image:scale(scaleX, scaleY)`](#imagescalescalex-scaley)
      - [`Image:scaleX(scaleX)`](#imagescalexscalex)
      - [`Image:scaleY(scaleY)`](#imagescaleyscaley)
  - [Paragraph](#paragraph)
    - [Functions](#functions-4)
      - [`Paragraph:color(r, g, b, a)`](#paragraphcolorr-g-b-a)
      - [`Paragraph:new(font, text, limit, align, x, y)`](#paragraphnewfont-text-limit-align-x-y)
      - [`Paragraph:scale(scaleX, scaleY)`](#paragraphscalescalex-scaley)
      - [`Paragraph:scaleX(scaleX)`](#paragraphscalexscalex)
      - [`Paragraph:scaleY(scaleY)`](#paragraphscaleyscaley)
      - [`Paragraph:shadowColor(r, g, b, a)`](#paragraphshadowcolorr-g-b-a)
      - [`Paragraph:shadowOffset(offsetX, offsetY)`](#paragraphshadowoffsetoffsetx-offsety)
      - [`Paragraph:shadowOffsetX(offsetX)`](#paragraphshadowoffsetxoffsetx)
      - [`Paragraph:shadowOffsetY(offsetY)`](#paragraphshadowoffsetyoffsety)
  - [Rectangle](#rectangle)
    - [Functions](#functions-5)
      - [`Rectangle:cornerRadius(radiusX, radiusY)`](#rectanglecornerradiusradiusx-radiusy)
      - [`Rectangle:cornerRadiusX(radius)`](#rectanglecornerradiusxradius)
      - [`Rectangle:cornerRadiusY(radius)`](#rectanglecornerradiusyradius)
      - [`Rectangle:cornerSegments(segments)`](#rectanglecornersegmentssegments)
      - [`Rectangle:fillColor(r, g, b, a)`](#rectanglefillcolorr-g-b-a)
      - [`Rectangle:new(x, y, width, height)`](#rectanglenewx-y-width-height)
      - [`Rectangle:outlineColor(r, g, b, a)`](#rectangleoutlinecolorr-g-b-a)
      - [`Rectangle:outlineWidth(width)`](#rectangleoutlinewidthwidth)
  - [Text](#text)
    - [Functions](#functions-6)
      - [`Text:color(r, g, b, a)`](#textcolorr-g-b-a)
      - [`Text:new(font, text, x, y)`](#textnewfont-text-x-y)
      - [`Text:scale(scaleX, scaleY)`](#textscalescalex-scaley)
      - [`Text:scaleX(scaleX)`](#textscalexscalex)
      - [`Text:scaleY(scaleY)`](#textscaleyscaley)
      - [`Text:shadowColor(r, g, b, a)`](#textshadowcolorr-g-b-a)
      - [`Text:shadowOffset(offsetX, offsetY)`](#textshadowoffsetoffsetx-offsety)
      - [`Text:shadowOffsetX(offsetX)`](#textshadowoffsetxoffsetx)
      - [`Text:shadowOffsetY(offsetY)`](#textshadowoffsetyoffsety)
  - [Ui](#ui)
    - [Functions](#functions-7)
      - [`Ui:beginChildren()`](#uibeginchildren)
      - [`Ui:draw()`](#uidraw)
      - [`Ui:endChildren()`](#uiendchildren)
      - [`local value = Ui:get(element, propertyName, ...)`](#local-value--uigetelement-propertyname)
      - [`local element = Ui:getElement(name)`](#local-element--uigetelementname)
      - [`local elementState = Ui:getState(element)`](#local-elementstate--uigetstateelement)
      - [`Ui:new(elementClass, ...)`](#uinewelementclass)
      - [`Ui:select(element)`](#uiselectelement)
      - [`Ui:start()`](#uistart)
- [Contributing](#contributing)

Installation
------------
To use Charm, place charm.lua in your project, and then `require` it in each file where you need to use it:

```lua
local charm = require 'charm' -- if your charm.lua is in the root directory
local charm = require 'path.to.charm' -- if it's in subfolders
```

API
---

### Base
A definition for a type of element that a `Ui` can draw.

#### Properties

##### `Base.get` (table)
A table of functions that can be accessed via `Ui.get`. Additional arguments to `Ui.get` will be passed to these functions, and `Ui.get` will return whatever these functions return.

##### `Base.preserve` (table)
A list of all of the keys of an element instance that should not be cleared out when a new draw frame is started.

#### Functions

##### `Base:afterDraw()`
Called after the element is drawn.

##### `Base:beforeDraw()`
Called before the element is drawn.

##### `Base:bottom(y)`
Sets the y position of the bottom edge of the element.

Parameters:
- `y` (`number`) - the desired y position

Returns:
- `state` (`table`)

##### `Base:center(x)`
Sets the x position of the horizontal center of the element.

Parameters:
- `x` (`number`) - the desired x position

##### `Base:clip()`
Enables clipping for this element, causing child elements to be drawn cropped to this element's visible area.

##### `local containsPoint = Base:containsPoint(x, y)`
Gets whether a point is within the element's bounds.

Returns:
- `containsPoint` (`boolean`)

##### `Base:drawSelf()`
Defines the drawing operations used to display the element on screen.

##### `local bottom = Base.get:bottom()`
Returns the y position of the bottom edge of the element.

Returns:
- `bottom` (`number`)

##### `local center = Base.get:center()`
Returns the x position of the horizontal center of the element.

Returns:
- `center` (`number`)

##### `local dragged = Base.get:dragged(button)`
Returns whether the element was dragged by a certain mouse button this frame, and if so, how far it was dragged.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `dragged` (`boolean`)
- `dx` (`number` or `nil`) - the number of pixels the element was dragged horizontally, or `nil` if it wasn't dragged
- `dy` (`number` or `nil`) - the number of pixels the element was dragged vertically, or `nil` if it wasn't dragged

##### `local entered = Base.get:entered()`
Returns whether the element was entered by the mouse this frame.

Returns:
- `entered` (`boolean`)

##### `local exited = Base.get:exited()`
Returns whether the element was exited by the mouse this frame.

Returns:
- `exited` (`boolean`)

##### `local height = Base.get:height()`
Returns the height of the element.

Returns:
- `height` (`number`)

##### `local held = Base.get:held(button)`
Returns whether the element was held by a certain mouse button this frame.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `held` (`boolean`)

##### `local hovered = Base.get:hovered()`
Returns whether the element was hovered by the mouse this frame.

Returns:
- `hovered` (`boolean`)

##### `local left = Base.get:left()`
Returns the x position of the left edge of the element.

Returns:
- `left` (`number`)

##### `local middle = Base.get:middle()`
Returns the y position of the vertical center of the element.

Returns:
- `middle` (`number`)

##### `local pressed = Base.get:pressed(button)`
Returns whether the element was pressed by a certain mouse button this frame.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `pressed` (`boolean`)

##### `local released = Base.get:released(button)`
Returns whether the element was released by a certain mouse button this frame.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `released` (`boolean`)

##### `local right = Base.get:right()`
Returns the x position of the right edge of the element.

Returns:
- `right` (`number`)

##### `local width, height = Base.get:size()`
Returns the width and height of the element.

Returns:
- `width` (`number`)
- `height` (`number`)

##### `local top = Base.get:top()`
Returns the y position of the top edge of the element.

Returns:
- `top` (`number`)

##### `local width = Base.get:width()`
Returns the width of the element.

Returns:
- `width` (`number`)

##### `local x = Base.get:x(anchor)`
Returns the x position of a certain point along the element's x-axis.

Parameters:
- `anchor` (`number`) (defaults to `0`) - the point along the x-axis to get (`0` is left, `.5` is center, `1` is right)

Returns:
- `x` (`number`)

##### `local y = Base.get:y(anchor)`
Returns the y position of a certain point along the element's y-axis.

Parameters:
- `anchor` (`number`) (defaults to `0`) - the point along the y-axis to get (`0` is top, `.5` is middle, `1` is bottom)

Returns:
- `y` (`number`)

##### `local z = Base.get:z()`
Returns the z position of the element.

Returns:
- `z` (`number`)

##### `local state = Base:getState()`
Gets the persistent state of the element.

##### `Base:height(height)`
Sets the height of the element.

Parameters:
- `height` (`number`)

##### `Base:left(x)`
Sets the x position of the left edge of the element.

Parameters:
- `x` (`number`) - the desired x position

##### `Base:middle(y)`
Sets the y position of the vertical center of the element.

Parameters:
- `y` (`number`) - the desired y position

##### `Base:name(name)`
Gives the element a name. This is required to use persistent state.

Parameters:
- `name` (`string`)

##### `Base:new(...)`
Called when the element is initialized. Additional arguments from `Ui.new` will be passed to this function.

##### `Base:onAddChild(element)`
Called when an element is added as this element's child.

Parameters:
- `element` (`Element`) - the child element

##### `Base:opaque()`
Sets the element to be opaque, meaning that this element will block mouse events from elements behind it.

##### `Base:right(x)`
Sets the x position of the right edge of the element.

Parameters:
- `x` (`number`) - the desired x position

##### `Base:size(width)`
Sets the width and height of the element.

Parameters:
- `width` (`number`)
- `height` (`number`)

##### `Base:shift(dx, dy)`
Shifts the element by a certain number of pixels horizontally and vertically.

Parameters:
- `dx` (`number`) (defaults to `0`) - the amount of the shift the element horizontally
- `dy` (`number`) (defaults to `0`) - the amount of the shift the element vertically

##### `Base:stencil()`
Defines the drawing operations used to crop child elements if clipping is enabled.

##### `Base:top(y)`
Sets the y position of the top edge of the element.

Parameters:
- `y` (`number`) - the desired y position

##### `Base:transparent()`
Sets the element to be transparent, meaning that mouse events can pass through this element to elements behind it.

##### `Base:width(width)`
Sets the width of the element.

Parameters:
- `width` (`number`)

##### `Base:wrap(padding)`
Adjusts the element to perfectly surround all of its children. The children's positions will be adjusted so they maintain the same position on screen.

Parameters:
- `padding` (`number`, defaults to `0`) - the amount of extra space to surround the children with

##### `Base:x(x, anchor)`
Sets the x position of a point along the element's x-axis.

Parameters:
- `x` (`number`) - the desired x position
- `anchor` (`number`) (defaults to `0`) - the position along the x-axis to set (`0` is left, `.5` is center, `1` is right)

##### `Base:y(y, anchor)`
Sets the y position of a point along the element's y-axis.

Parameters:
- `y` (`number`) - the desired y position
- `anchor` (`number`) (defaults to `0`) - the position along the y-axis to set (`0` is left, `.5` is center, `1` is right)

##### `Base:z(z)`
Sets the z position of the element.

Parameters:
- `z` (`number`)

### charm
The main module that lets you create new `Ui` objects and element classes.

#### Functions

##### `local ElementClass = charm.extend(parent)`
Creates a new element class.

Parameters:
- `parent` (`ElementClass` or `string`) (optional, defaults to `'base'`) - the element class the new class should inherit from

Returns:
- `elementClass` (`ElementClass`) - the new element class

##### `local ui = charm.new()`
Creates a new `Ui` object.

### Ellipse

#### Functions

##### `Ellipse:fillColor(r, g, b, a)`
Sets the color to draw the inside of the ellipse with.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Ellipse:new(x, y, width, height)`
Initializes the ellipse.

Parameters:
- `x` (`number`, defaults to `0`) - the x position of the ellipse
- `y` (`number`, defaults to `0`) - the y position of the ellipse
- `width` (`number`, defaults to `0`) - the width of the ellipse
- `height` (`number`, defaults to `0`) - the height of the ellipse

##### `Ellipse:outlineColor(r, g, b, a)`
Sets the color to draw the outline of the ellipse with.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Ellipse:outlineWidth(width)`
Sets the line width of the ellipse's outline.

Parameters:
- `width` (`number`)

##### `Ellipse:segments(segments)`
Sets the number of segments to draw the ellipse with.

Parameters:
- `segments` (`number`)

### Image

#### Functions

##### `Image:color(r, g, b, a)`
Sets the blend color of the image.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Image:new(image, x, y)`
Initializes the image.

Parameters:
- `image` (`Image`) - the image to use
- `x` (`number`, default to `0`) - the x position of the image
- `y` (`number`, default to `0`) - the y position of the image

##### `Image:scale(scaleX, scaleY)`
Sets the scale of the image (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`, defaults to `1`)
- `scaleY` (`number`, defaults to `scaleX`)

##### `Image:scaleX(scaleX)`
Sets the horizontal scale of the image (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`)

##### `Image:scaleY(scaleY)`
Sets the vertical scale of the image (as a multiplier of its original size).

Parameters:
- `scaleY` (`number`)

### Paragraph

#### Functions

##### `Paragraph:color(r, g, b, a)`
Sets the color of the paragraph.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Paragraph:new(font, text, limit, align, x, y)`
Initializes the paragraph.

Parameters:
- `font` (`Font`) - the font to use
- `text` (`string`) - the text to display
- `limit` (`number`) - the maximum horizontal width in pixels the text is allowed to span
- `align` (`AlignMode`) - the alignment of the text
- `x` (`number`, defaults to `0`) - the x position of the paragraph
- `y` (`number`, defaults to `0`) - the y position of the paragraph

##### `Paragraph:scale(scaleX, scaleY)`
Sets the scale of the paragraph (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`, defaults to `1`)
- `scaleY` (`number`, defaults to `scaleX`)

##### `Paragraph:scaleX(scaleX)`
Sets the horizontal scale of the paragraph (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`)

##### `Paragraph:scaleY(scaleY)`
Sets the vertical scale of the paragraph (as a multiplier of its original size).

Parameters:
- `scaleY` (`number`)

##### `Paragraph:shadowColor(r, g, b, a)`
Sets the color of the paragraph's shadow.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Paragraph:shadowOffset(offsetX, offsetY)`
Sets the horizontal and vertical offset of the paragraph's shadow.

Parameters:
- `offsetX` (`number`)
- `offsetY` (`number`)

##### `Paragraph:shadowOffsetX(offsetX)`
Sets the horizontal offset of the paragraph's shadow.

Parameters:
- `offsetX` (`number`)

##### `Paragraph:shadowOffsetY(offsetY)`
Sets the vertical offset of the paragraph's shadow.

Parameters:
- `offsetY` (`number`)

### Rectangle

#### Functions

##### `Rectangle:cornerRadius(radiusX, radiusY)`
Sets the horizontal and vertical radius of the rectangle's corners.

Parameters:
- `radiusX` (`number`)
- `radiusY` (`number`)

##### `Rectangle:cornerRadiusX(radius)`
Sets the horizontal radius of the rectangle's corners.

Parameters:
- `radiusX` (`number`)

##### `Rectangle:cornerRadiusY(radius)`
Sets the vertical radius of the rectangle's corners.

Parameters:
- `radiusY` (`number`)

##### `Rectangle:cornerSegments(segments)`
Sets the number of segments used to draw the rectangle's corners.

Parameters:
- `segments` (`number`)

##### `Rectangle:fillColor(r, g, b, a)`
Sets the color to draw the inside of the rectangle with.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Rectangle:new(x, y, width, height)`
Initializes the rectangle.

Parameters:
- `x` (`number`, defaults to `0`) - the x position of the rectangle
- `y` (`number`, defaults to `0`) - the y position of the rectangle
- `width` (`number`, defaults to `0`) - the width of the rectangle
- `height` (`number`, defaults to `0`) - the height of the rectangle

##### `Rectangle:outlineColor(r, g, b, a)`
Sets the color to draw the outline of the rectangle with.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Rectangle:outlineWidth(width)`
Sets the line width of the rectangle's outline.

Parameters:
- `width` (`number`)

### Text

#### Functions

##### `Text:color(r, g, b, a)`
Sets the color of the text.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Text:new(font, text, x, y)`
Initializes the text.

Parameters:
- `font` (`Font`) - the font to use
- `text` (`string`) - the text to display
- `x` (`number`, defaults to `0`) - the x position of the text
- `y` (`number`, defaults to `0`) - the y position of the text

##### `Text:scale(scaleX, scaleY)`
Sets the scale of the text (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`, defaults to `1`)
- `scaleY` (`number`, defaults to `scaleX`)

##### `Text:scaleX(scaleX)`
Sets the horizontal scale of the text (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`)

##### `Text:scaleY(scaleY)`
Sets the vertical scale of the text (as a multiplier of its original size).

Parameters:
- `scaleY` (`number`)

##### `Text:shadowColor(r, g, b, a)`
Sets the color of the text's shadow.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Text:shadowOffset(offsetX, offsetY)`
Sets the horizontal and vertical offset of the text's shadow.

Parameters:
- `offsetX` (`number`)
- `offsetY` (`number`)

##### `Text:shadowOffsetX(offsetX)`
Sets the horizontal offset of the text's shadow.

Parameters:
- `offsetX` (`number`)

##### `Text:shadowOffsetY(offsetY)`
Sets the vertical offset of the text's shadow.

Parameters:
- `offsetY` (`number`)

### Ui
Manages and draws graphical elements.

#### Functions

##### `Ui:beginChildren()`
Starts adding children to the currently selected element.

##### `Ui:draw()`
Draws the previously added elements and updates their state. After `draw` is called, the next `new` call will clear out the existing elements.

##### `Ui:endChildren()`
Stops adding children to the current parent element and re-selects the parent element.

##### `local value = Ui:get(element, propertyName, ...)`
Gets the value of an element property.

Parameters:
- `element` (`Element` or `string`) - the element or name of the element to get the property from
- `propertyName` (`string`) - the name of the property to get the value of
- `...` - additional arguments to pass to the property getter function

Returns:
- `value` - the value of the property

##### `local element = Ui:getElement(name)`
Gets the table representing an element.

Parameters:
- `name` (`string`) - the name of the element, or one of the following keywords:
  - `'@current'` - the currently selected element
  - `'@previous'` - the previously selected element
  - `'@parent'` - the parent of the currently selected element (if there is one)

Returns:
- `element` (`Element` or `nil`) - the element table, or `nil` if there's no element with the given name or no element that matches the given keyword

##### `local elementState = Ui:getState(element)`
Gets the persistent state table for an element.

Parameters:
- `element` (`Element` or `string`) - the element or name of the element to get the state of

Returns:
- `elementState` (`table` or `nil`) - the persistent state of the element, or `nil` if the element doesn't have a persistent state

##### `Ui:new(elementClass, ...)`
Adds a new element to be drawn this frame.

Parameters:
- `elementClass` (`ElementClass` or `string`) - the type of element to add
- `...` - additional arguments to pass to the element class' constructor

Returns:
- `self` (`Ui`) - itself

##### `Ui:select(element)`
Sets the element that subsequent function calls should modify.

Parameters:
- `element` (`Element`) - the element to select

##### `Ui:start()`
Manually starts a new draw frame. Normally this is called automatically the first time you call `Ui:new()` after calling `Ui:draw()`.

Returns:
- `self` (`Ui`) - itself

Contributing
------------
Charm is in very early development. Feel free to request features, point out bugs, and even make some pull requests! If you use this library in a game, let me know how it goes.
