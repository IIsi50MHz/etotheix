<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:ui="http://www.ais-sim.com/mongoose/ns/ui-controls"
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="html" indent="yes"/>	
	<!-- VARIABLES, KEYS, PARAMETERS -->
	<xsl:param name="category"/>
	<xsl:param name="searchTerm" select="''"/>  <!-- **change this to "searchTerm". Make it a parameter -->		
	<xsl:variable name="upperCase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="lowerCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:key name="category" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>	
	<xsl:key name="entry_data" match="ui:categorized_listbox/ui:entry/ui:entry_data" use="./../ui:category"/>	
	<xsl:key name="item" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>
	<xsl:key name="searchable" match="ui:categorized_listbox/ui:entry/ui:searchable" use="."/>
	<xsl:key name="field" match="ui:categorized_listbox/ui:entry/ui:searchable" use="."/>
			
	
	<!-- MAIN TEMPLATE -->
	<xsl:template match="/ui:categorized_listbox">				
		<!-- make a list of unique categories, but leave out all subcategories -->		
		<xsl:choose>
			<xsl:when test="$searchTerm = ''">
				<td  class="categorizedList">
					<div class="listWrapper">
						<!--generate list of subcategories-->
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
						<!--generate list of items-->
						<xsl:for-each select="key('entry_data', $category)">
							<xsl:sort select="name"/>												
								<p class="item" category="{$category}">					
									<xsl:if test="../ui:category[. = $category]/@selected">
										<xsl:attribute name="class">item selectMe</xsl:attribute>
									</xsl:if>
									<xsl:apply-templates select="."/>
								</p>					
						</xsl:for-each>
					</div>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<!--generate list of searched fields -->
				<td  class="root categorizedList">
					<div class="listWrapper">								
						<div class="fieldList">
							<p class="field" field="all">
								Show All Fields
							</p>
							<xsl:for-each select="ui:entry/ui:searchable[generate-id(.)=generate-id(key('searchable', .))]">													
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
						<div class="itemList">
							<xsl:for-each select="ui:entry/ui:searchable[generate-id(.)=generate-id(key('searchable', .))]">
								<xsl:call-template name="searchedItems">
									<xsl:with-param name="searchField" select="."/>
								</xsl:call-template>							
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
		<xsl:param name="searchField"/>		
		<div field="{$searchField}">
			<div style="border-bottom: solid grey 1px; margin-bottom: 5px;" num_results="{count(/ui:categorized_listbox/ui:entry//*[name() = $searchField][contains(concat(' ', translate(., $upperCase, $lowerCase)), concat(' ', translate($searchTerm, $upperCase, $lowerCase)))]/ancestor::ui:entry/ui:entry_data)}">
				<xsl:value-of select="$searchField/@field"/>			
			<!--	(<xsl:value-of select="count(/ui:categorized_listbox/ui:entry//*[name() = $searchField][contains(translate(., $upperCase, $lowerCase), translate($searchTerm, $upperCase, $lowerCase))]/ancestor::ui:entry/ui:entry_data)"/>)-->
			</div>
			<xsl:for-each select="/ui:categorized_listbox/ui:entry//*[name() = $searchField][contains(concat(' ', translate(., $upperCase, $lowerCase)), concat(' ', translate($searchTerm, $upperCase, $lowerCase)))]/ancestor::ui:entry/ui:entry_data">
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
		<p class="field" field="{.}" num_results="{count(/ui:categorized_listbox/ui:entry//*[name() = $searchField][contains(concat(' ', translate(., $upperCase, $lowerCase)), concat(' ', translate($searchTerm, $upperCase, $lowerCase)))]/ancestor::ui:entry/ui:entry_data)}">
			<xsl:value-of select="@field"/> (<xsl:value-of select="count(/ui:categorized_listbox/ui:entry//*[name() = $searchField][contains(concat(' ', translate(., $upperCase, $lowerCase)), concat(' ', translate($searchTerm, $upperCase, $lowerCase)))]/ancestor::ui:entry/ui:entry_data)"/>)
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