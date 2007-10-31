<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:ui="http://www.ais-sim.com/mongoose/ns/ui-controls"
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="html" indent="yes"/>	
	<xsl:param name="category"/>
	<xsl:key name="category" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>	
	<xsl:key name="entry_data" match="ui:categorized_listbox/ui:entry/ui:entry_data" use="./../ui:category"/>	
	<xsl:key name="item" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>
	<!-- VARIABLES -->		
	
	<!-- MAIN TEMPLATE -->
	<xsl:template match="/ui:categorized_listbox">				
		<!-- make a list of unique categories, but leave out all subcategories -->
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
	</xsl:template>

	<!-- TEMPLATES USED BY MAIN TEMPLATE -->
	<!-- create text list items -->
	<xsl:template match="ui:entry_data">	
		<xsl:value-of select="name"/>
			<td class="categorizedList itemInfo">
				<div class="listWrapper">
					<h1><xsl:value-of select="name"/></h1>
					<span><xsl:value-of select="full_description"/></span>
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