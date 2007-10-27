<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:ui="http://www.ais-sim.com/mongoose/ns/ui-controls"
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="html" indent="yes"/>	
	<xsl:param name="category" />
	<xsl:key name="category" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>	
	<xsl:key name="item" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>
	<!-- VARIABLES -->		
	
	<!-- MAIN TEMPLATE -->
	<xsl:template match="/ui:categorized_listbox">				
		<!-- make a list of unique categories, but leave out all subcategories -->
		<div class="categorizedList">
			<!--generate list of subcategories-->
			<xsl:for-each select="ui:entry/ui:category[generate-id(.)=generate-id(key('category', .))]">
			<!--<xsl:for-each select="ui:entry/ui:category[not(concat($category, '/', substring-before(concat(substring-after(., concat($category, '/')), '/'), '/'))=preceding::ui:entry/ui:category)]">-->
				<xsl:sort/>						
				<xsl:choose>
					<xsl:when test="starts-with(., concat($category, '/')) and not(contains(substring-after(., concat($category, '/')), '/'))">	
						<p category="{.}">						
							<xsl:value-of select="substring-after(., concat($category, '/'))"/>								
						</p>
					</xsl:when>
					<xsl:when test="starts-with(., concat($category, '/'))">	
						<p category="{concat($category, '/', substring-before(concat(substring-after(., concat($category, '/')), '/'), '/'))}">						
							<!--!!!<xsl:value-of select="substring-after(., concat($category, '/'))"/>		-->
							<xsl:value-of select="substring-before(concat(substring-after(., concat($category, '/')), '/'), '/')"/>	
						</p>
					</xsl:when>			
				</xsl:choose>
			</xsl:for-each>	
			<!--generate list of items-->
			<xsl:for-each select="key('category', $category)/../ui:entry_data">
				<xsl:sort/>						
					<p class="item">						
						<xsl:value-of select="name"/>
						<div class="categorizedList itemInfo">
							<h1><xsl:value-of select="name"/></h1>
							<span><xsl:value-of select="full_description"/></span>							
						</div>
					</p>	
			</xsl:for-each>
		</div>					
	</xsl:template>

	<!-- TEMPLATES USED BY MAIN TEMPLATE -->
	<!-- create text list items -->
	<xsl:template name="createList">	
	
	</xsl:template>	
</xsl:stylesheet>