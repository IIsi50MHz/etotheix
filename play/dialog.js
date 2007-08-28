/* dialog
- should wrap all dialogs in a single div
- don't auto generate any dialog contents
- do auto generate background and stuff...
- assume only one dialog visible at a time? only for modal... which will be most (all dialgos)
- make dialog container the background... then you don't have to auto generate anything...
- dialogs are selected and are only visible when selected.
- bringing up a dialog involves an exclusive select of the dialog, and making the dialog contiainer visible
- all children div's of dialog container are styled as dialogs...
- How do you hook up buttons? 
	1) Give buttons classes or attributes that say what they are for? "hides"
	2) use protoControl?
*/ 
var controls = {
	".tab": [
		{
			events: "click", 
			actOn: "self", 
			trigger: "tabSelect"
		},
		{
			events: "tabSelect", 
			actOn: "self, pane", 
			actions: "select",
			exclusive: true
		}
	]
}