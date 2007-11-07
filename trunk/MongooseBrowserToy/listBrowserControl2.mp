{{mongoose_page version="1.0" content_type="text/html"}}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	<head>
		<title>list browser</title>

		<!-- import the stylesheet -->
		<style type="text/css">
			.browser {				
				border: solid grey 6px;				
				overflow: auto;
			}
			.browserGroup {
				
			}
			.listWrapper {				
				width:250px;
				height: 300px;
				overflow: auto;
				background-color: lightblue;
				border: 4px solid grey;
				margin: 0px;
				padding: 5px;
			}
			.listWrapper p {
				cursor: pointer;
				border: 2px solid grey;
				padding: 5px;
				margin: 0px 0px 3px 0px;
			}
			.listWrapper p[category] {
				background-color: pink;
			}
			.listWrapper p[category].selected {
				background-color: red;
			}
			.listWrapper p.item {
				background-color: lightgreen;
			}
			.listWrapper p.item .itemInfo {
				display: none;
			}
			.listWrapper p.item.selected {
				background-color: green;
			}
			input {
				border: solid grey 4px;
				margin: 3px 5px 0px 3px;
				padding: 2px 4px;
				font-weight: bold;
			}
			.listWrapper input {
				border: solid grey 2px;
				margin: 0px 0px 3px 0px;
				padding: 2px 4px;
				font-weight: bold;
				width: 221px;
			}
			.browser table {
				display: none;
			}
			.browser table.selected {
				display: table;
			}
			div[num_results="0"], p[num_results="0"] {
				display: none;
			}
			.field.selected {
				background-color: #5895BB;				
			}
		</style>
		
		<!-- import the common scripts that we use with all of the pages -->
		<script type="text/javascript" src="/js/MochiKit/MochiKit-packed.js"></script>
		<script type="text/javascript" src="/js/MochiKit/New.js"></script>
		<script type="text/javascript" src="/js/jquery-latest.js"></script>		
		<script type="text/javascript" src="/js/transform.js"></script>
		<script type="text/javascript" src="/js/global.js"></script>
		<script type="text/javascript">	
		//** put this in gobal.js?
		(function ($) {	
			$.wait = function (func, waitTime) {
				var that = this;
				waitTime = waitTime || 500;
				clearTimeout(this.timeout);
				this.timeout = setTimeout(function () {
					// stuff to do if it's been long enough since last call
					func.call(that);
				}, waitTime);
			};			
		}) (jQuery);
		(function ($) {			
			path = "/xsl/";
			browserExample = {
				rootCategories: {
					xsl: path+"rootCategories2.xsl"
				},
				list: {
					xsl: path+"browserList(search)2.xsl", 
					xml: path+"listExample2.xml"
				}
			}				
			$.get(path+"addMissingCategories2.xsl", function (missingCategories) {	
				$.get(browserExample.list.xsl, function (xslDoc) {					
					browserExample.list.xsl = xslDoc;
					$.get(browserExample.rootCategories.xsl, function (xslDoc) {
						// get xsl for creating root category list
						browserExample.rootCategories.xsl = xslDoc;
						// get xml categorized list
						$.get(browserExample.list.xml, function (xmlDoc) {					
							browserExample.list.xml = $(xmlDoc);
							$(function () {
								list = browserExample.list.xml;																					
								missingCats = $(browserExample.list.xml).transform({xsl: missingCategories});
								list.find('categorized_listbox').prepend(missingCats);								
								list.transform({xsl: xslDoc}).appendTo(".root .listWrapper");	
								/////
								// chooseCategory (this: clicked category)
								/////
								chooseCategory = function () {					
									var thisCategoryList, rootFieldList, thisInput, thisBrowser; //**change input to thisInput?
									//**can we make these element selectors faster? Hook them to top of list? Give them id's?
									chosenCategory = $(this);
									thisBrowser = chosenCategory.parents('.browser');
									rootListContainer = thisBrowser.find('.root.categorizedList:eq(0)');
									rootFieldList = rootListContainer.find(".fieldList:eq(0)"); //**need to change the class name from "categorizedList" to something like "list"?																		
									rootCategoryList = rootListContainer.find(".rootCategoryList");
									thisListContainer = chosenCategory.parents(".categorizedList");									
									thisCategoryList = chosenCategory.parents(".categoryList").eq(0);																		
									thisInput = thisCategoryList.siblings("input");	//**input should be inside listWrapper, sibling of "categoryList"					
									thisItemList = thisCategoryList.siblings(".itemList");					
									
									// select chosen category
									f.debug("thisCategoryList", thisListContainer[0])
									if (thisListContainer[0]) { //**shouldn't have to do this check
										if (thisListContainer[0].mongooseSelectedElement) thisListContainer[0].mongooseSelectedElement.removeClass("selected");
										thisListContainer[0].mongooseSelectedElement = $(this).addClass("selected");									
									}
									// if there is a search term, do a search **this needs to limit search to selected category and selected field
									if (thisInput.val() && false) { //**get rid of this
										f.debug("seraching!", thisInput.val())
										searchList.call(thisInput);
									} else {
										f.debug("chooseing",thisListContainer.next().find("input").val(),thisListContainer.next().prev(), chosenCategory, thisListContainer)
										var nextInput = thisListContainer.next().find("input");
										var searchTerm = nextInput.val();										
										f.debug("chooseing",thisListContainer.next().find("input").val(), searchTerm)
										thisListContainer.next().nextAll().remove();									
										results = list.transform({
											xsl: browserExample.list.xsl, 
											params: {
												category: chosenCategory.attr('category'),
												searchTerm: searchTerm || '',
												selectedField: (rootListContainer[0].mongooseSelectedFieldElement && rootListContainer[0].mongooseSelectedFieldElement.attr("field")) || "All Fields"
											}
										});
										if (!searchTerm) {
											thisListContainer.nextAll().remove();
											results.eq(1).insertAfter(thisListContainer).find("input:eq(0)").highlightFocus();											
											//results.eq(1).find(".categoryList, .itemList").insertAfter(nextInput);
											
											var fieldList = results.find(".fieldList");
											rootListContainer[0].mongooseSelectedFieldElement = fieldList.find(".selected");
											rootCategoryList.siblings().remove();
											fieldList.insertBefore(rootCategoryList);										
											
											//thisListContainer.next().nextAll().remove();
											//nextInput.siblings().remove();
											//results.eq(1).find(".categoryList, .itemList").insertAfter(nextInput);
											//rootCategoryList.siblings().remove();
											//results.find(".fieldList").insertBefore(rootCategoryList);
											//thisListContainer.next().nextAll().remove();
											//results.eq(1).find(".itemList").replaceAll(nextItemList);
										} else {
											thisInput.val('');
											
											var fieldList = results.find(".fieldList");
											rootListContainer[0].mongooseSelectedFieldElement = fieldList.find(".selected");
											rootCategoryList.siblings().remove();
											fieldList.insertBefore(rootCategoryList);		
											
											nextInput.siblings().remove();
											results.eq(1).find(".categoryList, .itemList").insertAfter(nextInput);
										}
									}
								};
								/////
								// chooseItem (this: clicked item)
								/////
								chooseItem = function () {									
									var subList = $(this).parents(".categorizedList").eq(0);	
									// select chosen item
									if (subList.length) {
										if (subList[0].mongooseSelectedElement) {
											subList[0].mongooseSelectedElement.removeClass("selected");
										}									
										subList[0].mongooseSelectedElement = $(this).addClass("selected");
										subList.nextAll().remove();
										$(this).find(".itemInfo").clone().insertAfter(subList);						
									}																		
								};
								/////
								// searchList (this: input)
								/////
								searchListWait = function (waitTime) {		
									if (typeof waitTime !== "number") waitTime = 500;
									f.debug("waitTime", waitTime)
									//** what is "this" here? ***search input
									$.wait.call(this, searchList, waitTime);			
								};
								searchList = function () {	
										f.debug("seraring for rals!!!", this)
										var searchTerm, rootListContainer, input, rootCategoryList;
										thisInput = $(this);										
										searchTerm = thisInput.val();
										thisBrowser = thisInput.parents('.browser');
										rootListContainer = thisBrowser.find('.root.categorizedList:eq(0)');
										rootFieldList = rootListContainer.find(".fieldList:eq(0)"); //**need to change the class name from "categorizedList" to something like "list"?
										rootCategoryList = rootListContainer.find(".rootCategoryList");
										thisListContainer = thisInput.parents(".categorizedList");									
										thisCategoryList = thisInput.siblings(".categoryList");	
										thisItemList = thisInput.siblings(".itemList");																				
										
										if (thisListContainer[0].mongooseSelectedElement) {
											thisListContainer[0].mongooseSelectedElement.removeClass("selected");
											delete thisListContainer[0].mongooseSelectedElement;
										}
										//thisCategoryList.find(".selected[@category]").removeClass("selected");										
										/*if (rootCategoryList.length) {	
											rootCategoryList = rootCategoryList.clone();
										} else {
											rootCategoryList = thisInput.parent('.browser').find(".rootCategoryList").clone;
										}*/
										if (!searchTerm) {		
											f.debug("no search term!!!", this, searchTerm)
											f.debug("asdf", rootCategoryList.find(".fieldList"))
											rootCategoryList.siblings(".fieldList").remove();
											chooseCategory.call(thisListContainer.prev().find(".selected[@category]")) //**selected category stored on list. use it instead?
											//thisInput.parent('.browser').find(">table.browseByCategory").show().siblings("table").hide();											
										} else {											
											//thisInput.parent('.browser').find(">table.browseByFieldSearch").show().siblings("table").hide();																						
											// do search																	
											f.debug("a", (rootListContainer[0].mongooseSelectedFieldElement))
											results = list.transform({
												xsl: browserExample.list.xsl, 
												params: {												
													searchTerm: searchTerm,
													category: thisListContainer.prev()[0].mongooseSelectedElement && thisListContainer.prev()[0].mongooseSelectedElement.attr("category") || '',
													selectedField: (rootListContainer[0].mongooseSelectedFieldElement && rootListContainer[0].mongooseSelectedFieldElement.attr("field")) || "All Fields"
												}
											});
											//f.debug("a", (rootCategoryList[0].mongooseSelectedFieldElement))											
											var fieldList = results.find(".fieldList");
											rootListContainer[0].mongooseSelectedFieldElement = fieldList.find(".selected");
											rootCategoryList.siblings(".fieldList").replaceWith(fieldList);											
											thisListContainer.nextAll().remove();
											results.eq(1).find(".itemList").replaceAll(thisItemList);									
										}
										//$("#searchingMessage").hide();													
								};
								/////
								// filterFields (this: clicked field)
								/////
								filterFields = function (e, delegator) {
									var subList = $(this).parents(".categorizedList").eq(0);
									// select a field
									if (subList.length) {
										if (subList[0].mongooseSelectedFieldElement) {
											subList[0].mongooseSelectedFieldElement.removeClass("selected");
										}									
										subList[0].mongooseSelectedFieldElement = $(this).addClass("selected");															
									}		
									// show items matching field **need to be using xsl transform instead of jQuery here. Use chooseCategory() as a model
									var field = $(this).attr("field");
									if (subList.next().length) {
										var lastInput = subList.siblings(':not(.itemInfo):last()').find("input");
										if (lastInput.val()) searchList.call(lastInput);
									}									
									//$(this).addClass("selected").siblings().removeClass("selected");
								}								
								$("body > div.browser").delegate("input", "keyup", searchListWait);
								$("body > div.browser").delegate("p[@category]:not(.item)", "mousedown", chooseCategory);
								$("body > div.browser").delegate("p.item", "mousedown", chooseItem);
								$("body > div.browser").delegate("td.root p.field", "mousedown", filterFields);
								/////
								// setSelectionPath (selection: object with properties for category, uuid, searchTerm, fieldSelection)
								/////
								setSelectionPath = function (selection) {
									if (selection.category) {
										// create a path								
										var leadingPath, categoryList, categoryElem, selectedItem,
											pathSplit = selection.category.split('/'), 
											that = this;									
										$.each(pathSplit, function (i, val) {										
											leadingPath = selection.category.split('/').splice(0, i+1).join('/');
											catagoryList = $(that).find('.categorizedList').eq(i)
											categoryElem = catagoryList.find("[@category="+leadingPath+"]");
											chooseCategory.apply(categoryElem);										
										});	
										selectedItem = catagoryList.next().find('.selectMe');
										chooseItem.apply(selectedItem);										
									}
								}
								var theSelection = list.find("selection:eq(0)");								
								var theCategory = theSelection.find("category_selection").text();
								var theUuid = list.find("entry_uuid").text();
								var theSearchTerm = list.find("search_term").text();								
								setSelectionPath.call($('#aBrowser'), {
									category: theCategory,
									uuid: theUuid,
									searchTerm: theSearchTerm
								});								
							});
						})
					});
				});
			});
			$.get(path+"allCaltegories.xsl", function (xslDoc) {
				allCategories = xslDoc;
			});
			$.get(path+"addMissingCategories.xsl", function (xslDoc) {
				addMissingCategories = xslDoc;
			});
		})(jQuery)
		</script>
	</head>
	
	<body>		
		<div id="aBrowser" class="browser">			
			<table class="browseByCategory selected">
				<tr class="browserGroup">				
					<td id="root" class="root categorizedList">
						<div class="listWrapper">
							<!--<input class="listSearch" type="text"/>-->
						</div>
					</td>	
				</tr>
			</table>			
		</div>
	</body>
</html>
