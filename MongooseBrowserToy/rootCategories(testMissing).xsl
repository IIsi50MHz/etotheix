<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:ui="http://www.ais-sim.com/mongoose/ns/ui-controls"
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="html" indent="yes"/>		
	<xsl:key name="category" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>
	<!-- VARIABLES -->		
	
	<!-- MAIN TEMPLATE -->
	<xsl:template match="/ui:categorized_listbox">				
		<!-- make a list of unique categories, but leave out all subcategories -->
		<xsl:for-each select="ui:entry/ui:category[generate-id(.)=generate-id(key('category', .))]">
		<xsl:sort/>																							
			<xsl:call-template name='missing'>
				<xsl:with-param name="beforeSlash" select="substring-before(., '/')"/>
				<xsl:with-param name="afterSlash" select="substring-after(., '/')"/>
			</xsl:call-template>
		</xsl:for-each>		
	</xsl:template>

	<!-- TEMPLATES USED BY MAIN TEMPLATE -->
	<!-- create text list items -->	
	<xsl:template match="ui:category">	
		<!--<xsl:if test="contains(., '/')">-->	
			<p category="{.}">	
				-!-<xsl:apply-templates/>-!-
				<xsl:call-template name='missing'>
					<xsl:with-param name="beforeSlash" select="substring-before(., '/')"/>
					<xsl:with-param name="afterSlash" select="substring-after(., '/')"/>
				</xsl:call-template>
			</p>
	<!--	</xsl:if>-->	
	</xsl:template>
	<xsl:template name="missing">		
		<xsl:param name="beforeSlash"/>
		<xsl:param name="afterSlash"/>	
		<xsl:if test="$afterSlash != ''">
			<p category="{.}">
				[<xsl:value-of select="."/>]<br/>				 
				(<xsl:value-of select="$beforeSlash"/>)(<xsl:value-of select="$afterSlash"/>)<br/>
				[<xsl:value-of select="substring(., 1, string-length(concat($beforeSlash, substring-before($afterSlash, '/'), 'x')))"/>]<br/>
				[<xsl:value-of select="substring(., string-length(concat($beforeSlash, substring-before($afterSlash, '/'), 'xxx')))"/>]
			</p>
			<xsl:if test="substring-after($afterSlash, '/') != ''">
				<xsl:call-template name="missing">
					<xsl:with-param name="beforeSlash" select="substring(., 1, string-length(concat($beforeSlash, substring-before($afterSlash, '/'), 'x')))"/>
					<xsl:with-param name="afterSlash" select="substring(., string-length(concat($beforeSlash, substring-before($afterSlash, '/'), 'xxx')))"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template name="nothing">		
	</xsl:template>
</xsl:stylesheet>