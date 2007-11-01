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
				margin: 3px 0px 0px 3px;
				padding: 2px 4px;
				font-weight: bold;
			}
			.browser table {
				display: none;
			}
			.browser table.selected {
				display: table;
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
					xsl: path+"rootCategories.xsl"
				},
				list: {
					xsl: path+"browserList(search).xsl", 
					xml: path+"listExample.xml"
				}
			}				
			$.get(path+"addMissingCategories.xsl", function (missingCategories) {	
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
								
								//** use jQuery to create missing categores
								/*
								// create category document
								catDoc = jQuery(browserExample.list.xml).transformToDoc({xsl: allCategories});
								catDocRoot = catDoc.find('entry').eq(0);
								// missing categories to document
								catDoc.find('category').each(function () {
								    var that = jQuery(this);
								    var parentCategory = that.text();
								    function addMissing (parentCat) {
								        if (parentCat) {
								            console.debug(parentCat)
								            parentCat = parentCat.match(/.*[/]/) || [''];
								            parentCat = parentCat[0].replace(/^(.*)[/]$/, '$1') || '';            
								            //console.debug(parentCat)
								            addMissing(parentCat);
								            if (parentCat) that.clone().text(parentCat).appendTo(catDocRoot);
								        }
								    }
								    addMissing(parentCategory);
								});
								*/
								// stick all this categories into main document
								//list.find('categorized_listbox').prepend(catDocRoot);								
								missingCats = $(browserExample.list.xml).transform({xsl: missingCategories});
								list.find('categorized_listbox').prepend(missingCats);
								
								
								list.transform({xsl: xslDoc}).appendTo(".root .listWrapper");
								//list.transform({xsl: browserExample.list.xsl});
								chooseCategory = function () {									
									var subList = $(this).parents(".categorizedList").eq(0);																
									// select chosen category
									if (subList[0].mongooseSelectedElement) subList[0].mongooseSelectedElement.removeClass("selected");
									subList[0].mongooseSelectedElement = $(this).addClass("selected");									
									
									subList.nextAll().remove();									
									list.transform({
										xsl: browserExample.list.xsl, 
										params: {
											category: $(this).attr('category'),
											searchTerm: ''
										}
									}).insertAfter(subList);								
								};
								chooseItem = function () {									
									var subList = $(this).parents(".categorizedList").eq(0);	
									// select chosen item
									if (subList[0].mongooseSelectedElement) subList[0].mongooseSelectedElement.removeClass("selected");
									subList[0].mongooseSelectedElement = $(this).addClass("selected");			
									
									subList.nextAll().remove();
									$(this).find(".itemInfo").clone().insertAfter(subList);						
								};
								searchList = function () {						
									$.wait.call(this, function () {
										var input = $(this);
										var searchTerm = input.val();
										console.debug(searchTerm)
										var listContainer = $(this).parent('.browser').find('.browseByFieldSearch .root').parent();
										if (!searchTerm) {											
											input.parent('.browser').find(".browseByCategory").addClass("selected").siblings("table").removeClass("selected");											
										} else {											
											input.parent('.browser').find(".browseByFieldSearch").addClass("selected").siblings("table").removeClass("selected");																						
											// do search																	
											var results = list.transform({
												xsl: browserExample.list.xsl, 
												params: {												
													searchTerm: searchTerm												
												}
											});
											listContainer.empty().append(results);
										}
									}, 500);					
								};
								$(".listSearch").keyup(searchList);
								$("body > div.browser").delegate("p[@category]:not(.item)", "mousedown", chooseCategory);
								$("body > div.browser").delegate("p.item", "mousedown", chooseItem);					
								setSelectionPath = function (path) {
									// create a path
									var leadingPath, categoryList, categoryElem,
										pathSplit = path.split('/'), 
										that = this;									
									$.each(pathSplit, function (i, val) {										
										leadingPath = path.split('/').splice(0, i+1).join('/');
										catagoryList = $(that).find('.categorizedList').eq(i)
										categoryElem = catagoryList.find("[@category="+leadingPath+"]");
										chooseCategory.apply(categoryElem);										
									});									
									chooseItem.call(catagoryList.next().find('.selectMe'));
								}
								var thePath = list.find('category[@selected]').text();
								console.debug(thePath);
								setSelectionPath.call($('#aBrowser'), thePath);								
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
			<input class="listSearch" type="text"/>
			<table class="browseByCategory selected">
				<tr class="browserGroup">				
					<td id="root" class="root categorizedList">
						<div class="listWrapper"></div>
					</td>	
				</tr>
			</table>
			<table class="browseByFieldSearch">
				<tr class="browserGroup">				
					<td id="root" class="root categorizedList">
						<div class="listWrapper"></div>
					</td>	
				</tr>
			</table>
		</div>
	</body>
</html>
