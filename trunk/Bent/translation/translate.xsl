<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:output method="html" indent="yes"/>	
	<!--get rid of useless text nodes-->
	<xsl:strip-space elements="*"/>	
	<!--grab translation file-->
	<xsl:variable name="translations" select="document('translate.xml')/translations"/>	
	<!--key for doing translations-->
	<xsl:key name="translate" match="to" use="../from"/>
	
	<!--identity transform (what comes in goes out... except text nodes)-->
	<xsl:template match="/|@*|node()">	
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>		
	</xsl:template>
	
	<!--translate text nodes-->
	<xsl:template match="text()">		
		<xsl:apply-templates select="$translations" mode="translate">
			<xsl:with-param name="text" select="."/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!--here's where the translation really happens-->
	<xsl:template match="translations" mode="translate">
		<xsl:param name="text"/>
		<xsl:value-of select="key('translate', $text)"/>
	</xsl:template>	
	
	<!--oh, and don't translate these text nodes (stuff in head, script elements, etc.)-->
	<xsl:template match="text()[ancestor::head|ancestor::script|ancestor::xsl:attribute]">	
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>	
	</xsl:template>
</xsl:stylesheet>


