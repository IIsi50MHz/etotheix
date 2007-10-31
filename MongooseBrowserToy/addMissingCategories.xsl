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
		<!-- create possibly missing categories -->
		<ui:entry>
			<xsl:for-each select="ui:entry/ui:category[generate-id(.)=generate-id(key('category', .))]">
			<xsl:sort/>																							
				<xsl:call-template name='missing'>
					<xsl:with-param name="beforeSlash" select="substring-before(., '/')"/>
					<xsl:with-param name="afterSlash" select="substring-after(., '/')"/>
				</xsl:call-template>
			</xsl:for-each>		
		</ui:entry>
	</xsl:template>

	<!-- TEMPLATES USED BY MAIN TEMPLATE -->
	<xsl:template name="missing">		
		<xsl:param name="beforeSlash"/>
		<xsl:param name="afterSlash"/>	
		<xsl:if test="$afterSlash != ''">
			<xsl:if test="not(key('category', $beforeSlash))">
				<ui:category><xsl:value-of select="$beforeSlash"/></ui:category>
			</xsl:if>
			<xsl:if test="substring-after($afterSlash, '/') != ''">
				<xsl:call-template name="missing">
					<xsl:with-param name="beforeSlash" select="substring(., 1, string-length(concat($beforeSlash, substring-before($afterSlash, '/'), 'x')))"/>
					<xsl:with-param name="afterSlash" select="substring(., string-length(concat($beforeSlash, substring-before($afterSlash, '/'), 'xxx')))"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>