<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:ui="http://www.ais-sim.com/mongoose/ns/ui-controls"
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="html" indent="yes"/>	
	<!-- VARIABLES, KEYS, PARAMETERS -->
	<xsl:param name="category" select="ui:categorized_listbox/ui:selection/ui:category_selection"/>
	<xsl:param name="selected_entry_uuid" select="ui:categorized_listbox/ui:selection/ui:entry_uuid"/>	
	<xsl:param name="searchTerm" select="ui:categorized_listbox/ui:selection/ui:search_term"/>  <!-- **change this to "searchTerm". Make it a parameter -->	
	<xsl:param name="selectedField" select="ui:categorized_listbox/ui:selection/ui:selected_field"/>  <!-- **change this to "searchTerm". Make it a parameter -->	
	<xsl:variable name="upperCase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="lowerCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:variable name="allFields" select="'All Fields'"/>
	<xsl:key name="category" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>	
	<xsl:key name="entry_data" match="ui:categorized_listbox/ui:entry/ui:entry_data" use="./../ui:category"/>
	<xsl:key name="entry_by_category" match="ui:categorized_listbox/ui:entry" use="./ui:category"/>	
	<xsl:key name="item" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>
	<xsl:key name="searchable" match="ui:categorized_listbox/ui:entry/ui:searchable" use="."/>
	<xsl:key name="field" match="ui:categorized_listbox/ui:entry/ui:searchable" use="."/>
	<xsl:key name="entry_by_uuid" match="ui:categorized_listbox/ui:entry" use="./@uuid"/>
	<xsl:key name="entry_by_searchable_field" match="ui:categorized_listbox/ui:entry" use="./ui:entry_data/*/@ui:searchable"/>
	<xsl:key name="searchable_field" match="ui:categorized_listbox/ui:entry//*[@ui:searchable]" use="./@ui:searchable"/>	
			
	
	<!-- MAIN TEMPLATE -->
	<xsl:template match="/ui:categorized_listbox">				
		<!-- make a list of unique categories, but leave out all subcategories -->		
		<xsl:choose>
			<!-- NO SEARCH -->
			<xsl:when test="$searchTerm = ''">
				<!--generate list of searched fields -->
				<td  class="categorizedList">
					<div class="listWrapper">								
						<div class="fieldList">
							<p class="field" field="{$allFields}">
								<xsl:if test="$selectedField = $allFields or $selectedField = ''">
									<xsl:attribute name="class">field selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="$allFields"/>
							</p>
							<xsl:for-each select="ui:entry//*[@ui:searchable][generate-id(.)=generate-id(key('searchable_field', ./@ui:searchable))]/@ui:searchable">													
								<p class="field" field="{.}">
									<xsl:if test=". = $selectedField">
										<xsl:attribute name="class">field selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="."/>
								</p>								
							</xsl:for-each>
						</div>
					</div>
				</td>
				<td class="categorizedList">
					<div class="listWrapper">
						<input type="text" value="{$searchTerm}"/>						
						<!--generate list of items-->
						<div class="itemList">
							<xsl:for-each select="key('entry_data', $category)">
								<xsl:sort select="name"/> <!--**might need to get rid of this sort. Let sort happen on backend-->												
									<p class="item {$selected_entry_uuid} {../@uuid}" category="{$category}">					
										<xsl:if test="../@uuid = $selected_entry_uuid">
											<xsl:attribute name="class">item selectMe</xsl:attribute>
										</xsl:if>
										<xsl:apply-templates select="."/>
									</p>					
							</xsl:for-each>
						</div>
						<!--generate list of subcategories-->
						<div class="categoryList">
							<xsl:for-each select="ui:entry/ui:category[generate-id(.)=generate-id(key('category', .))]">			
								<xsl:sort/>						
								<xsl:choose>
									<xsl:when test="starts-with(., concat($category, '/')) and not(contains(substring-after(., concat($category, '/')), '/'))">	
										<p category="{.}">						
											<xsl:value-of select="substring-after(., concat($category, '/'))"/>								
										</p>
									</xsl:when>				
								</xsl:choose>
							</xsl:for-each>	
						</div>
					</div>
				</td>
			</xsl:when>
			<!-- YES SEARCH -->
			<xsl:otherwise>
				<!--generate list of searched fields -->
				<td  class="categorizedList">
					<div class="listWrapper">								
						<div class="fieldList">
							<p class="field" field="{$allFields}">
								<xsl:if test="$selectedField = $allFields or $selectedField = ''">
									<xsl:attribute name="class">field selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="$allFields"/>
							</p>
							<xsl:for-each select="ui:entry//*[@ui:searchable][generate-id(.)=generate-id(key('searchable_field', ./@ui:searchable))]/@ui:searchable">																					
								<xsl:call-template name="searchedFields">									
									<xsl:with-param name="searchField" select="."/>									
								</xsl:call-template>																		
							</xsl:for-each>
						</div>
					</div>
				</td>
				<!--generate list of searched items-->
				<td  class="categorizedList">
					<div class="listWrapper">
						<input type="text" value="{$searchTerm}" class="{$selectedField}"/>						
						<!--generate list of items-->
						<div class="itemList">							
							<xsl:variable name="searchableFields" select="ui:entry//*[@ui:searchable][generate-id(.)=generate-id(key('searchable_field', ./@ui:searchable))]/@ui:searchable"/>						
							<xsl:choose>
								<!--search in all searchable fields-->
								<xsl:when test="$selectedField = $allFields or $selectedField = ''">									
									<xsl:call-template name="searchedItems">
										<xsl:with-param name="searchField" select="$allFields"/>
										<xsl:with-param name="searchMatch" select="key('entry_by_category', $category)//*[contains(translate(., $upperCase, $lowerCase), translate($searchTerm, $upperCase, $lowerCase))]/ancestor::ui:entry"/>													
									</xsl:call-template>									
								</xsl:when>								
								<!--search in selected searchable field only-->
								<xsl:otherwise>
									<xsl:call-template name="searchedItems">
										<xsl:with-param name="searchField" select="."/>
										<xsl:with-param name="searchMatch" select="key('entry_by_category', $category)//*[@ui:searchable = $selectedField][contains(translate(., $upperCase, $lowerCase), translate($searchTerm, $upperCase, $lowerCase))]/ancestor::ui:entry"/>												
									</xsl:call-template>				
								</xsl:otherwise>
							</xsl:choose>							
						</div>
						<!--generate list of subcategories-->
						<div class="categoryList">
							<xsl:for-each select="ui:entry/ui:category[generate-id(.)=generate-id(key('category', .))]">			
								<xsl:sort/>						
								<xsl:choose>
									<xsl:when test="starts-with(., concat($category, '/')) and not(contains(substring-after(., concat($category, '/')), '/'))">	
										<p category="{.}">						
											<xsl:value-of select="substring-after(., concat($category, '/'))"/>								
										</p>
									</xsl:when>				
								</xsl:choose>
							</xsl:for-each>	
						</div>						
					</div>
				</td>				
			</xsl:otherwise>
		</xsl:choose>								
	</xsl:template>

	<!-- TEMPLATES USED BY MAIN TEMPLATE -->
	<!-- search -->
	<!--searched Items-->
	<xsl:template name="searchedItems">
		<xsl:param name="searchField" select="$allFields"/>
		<xsl:param name="searchMatch"/>		
		<xsl:variable name="count" select="count($searchMatch)"/>		
		<div field="{$searchField}">			
			<div style="border-bottom: solid grey 1px; margin-bottom: 5px;"> <!--**take out style, put in css-->
				<xsl:value-of select="$selectedField"/> 
				(<xsl:value-of select="$count"/>)				
			</div>
			<xsl:for-each select="$searchMatch/ui:entry_data">
				<xsl:sort select="name"/>												
					<p class="item" category="{$category}">							
						<xsl:apply-templates select="."/>						
					</p>					
			</xsl:for-each>
		</div>
	</xsl:template>	
	<!--searched fields-->
	<xsl:template name="searchedFields">
		<xsl:param name="searchField"/>
		<xsl:variable name="searchMatch" select="key('searchable_field', $searchField)[ancestor::ui:entry/ui:category = $category or $category = ''][contains(translate(., $upperCase, $lowerCase), translate($searchTerm, $upperCase, $lowerCase))]/ancestor::ui:entry"/>				
		<xsl:variable name="count" select="count($searchMatch)"/>
		<p class="field" field="{$searchField}"> 
			<xsl:if test=". = $selectedField">
				<xsl:attribute name="class">field selected</xsl:attribute>
			</xsl:if>			
			<xsl:value-of select="$searchField"/> (<xsl:value-of select="$count"/>)				
		</p>
	</xsl:template>	
	<!-- create text list items -->
	<xsl:template match="ui:entry_data">	
		<xsl:value-of select="name"/>
			<td class="categorizedList itemInfo">
				<div class="listWrapper">
					<h1><xsl:value-of select="name"/></h1>
					<div><xsl:value-of select="short_description"/></div>
					<i><xsl:value-of select="full_description"/></i>
				</div>
			</td>			
	</xsl:template>		
	<xsl:template match="ui:entry_data[../@dong]">	
		<xsl:value-of select="name"/><br/>
		<xsl:value-of select="full_description"/>
			<td class="categorizedList itemInfo">
				<div class="listWrapper">
					<h1><xsl:value-of select="name"/></h1>
					<span><xsl:value-of select="full_description"/></span>
				</div>
			</td>			
	</xsl:template>	
	<xsl:template match="ui:entry_data[@ding]">	
		<i><xsl:value-of select="name"/></i><br/>
		<b><xsl:value-of select="full_description"/></b>
			<td class="categorizedList itemInfo">
				<div class="listWrapper">
					<h3><xsl:value-of select="name"/></h3>
					<span><xsl:value-of select="full_description"/></span>
				</div>
			</td>			
	</xsl:template>	
</xsl:stylesheet>