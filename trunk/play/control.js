// Selector (tabs or buttons are examples of selectors) (mongoose event list, mongoose target list, trainee tabs, etc.) ** would "Control" be a better name?
// 	A selector element can effect one (or more?) elements when an event happens
//	What sort of mark-up should we use to indicate what elements a selector element affects?
//		- use href = id of affected element. That means selector would have to be an anchor. Do we want that?
//		- have one or more hidden anchors inside selector element that refer to affected elements
//		- href value could be a jQuery expression? (css selector, xpath)
//	Use event delegation for potentially transient selectors, or where there are multiple selectors present that can use the same event handler.
/*
delegator = delegator
container = wrapper
item = control

*/






