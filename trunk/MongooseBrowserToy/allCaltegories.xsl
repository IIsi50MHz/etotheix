<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:ui="http://www.ais-sim.com/mongoose/ns/ui-controls"
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="xml" indent="yes"/>		
	<xsl:key name="category" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>
	<!-- VARIABLES -->		
	
	<!-- MAIN TEMPLATE -->
	<xsl:template match="/ui:categorized_listbox">				
		<!-- make a list of unique categories, but leave out all subcategories -->
		<ui:categorized_listbox>
		<ui:entry>
			<xsl:for-each select="ui:entry/ui:category[generate-id(.)=generate-id(key('category', .))]">
			<xsl:sort/>						
				<xsl:copy-of select="."/>						
			</xsl:for-each>
		</ui:entry>
		</ui:categorized_listbox>
	</xsl:template>

	<!-- TEMPLATES USED BY MAIN TEMPLATE -->
	<!-- create text list items -->
	<xsl:template name="createList">	
	
	</xsl:template>	
</xsl:stylesheet>