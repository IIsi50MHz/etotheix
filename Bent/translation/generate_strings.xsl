<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:output method="html" indent="no"/>
	<!--get rid of useless text nodes-->
	<xsl:strip-space elements="*"/>	
	<!--list of files to grab strings from-->
	<xsl:variable name="file_names" select="document('file_list.xml')/files/file"/>	
	<!--grab all files in list-->
	<xsl:variable name="files" select="document($file_names)"/>	
		
	<xsl:template match="/">
		<translations>			
			<xsl:apply-templates select="$files//text()"/>			
		</translations>
	</xsl:template>	
	
	<!--grab all text nodes (exceptions below)-->
	<xsl:template match="text()">
		<translate>
			<from><xsl:value-of select="."/></from>
			<to></to>
		</translate>
	</xsl:template>
	
	<!--don't grab these text nodes (stuff in head, script elements, etc.)-->
	<xsl:template match="text()[ancestor::head|ancestor::script|ancestor::xsl:attribute]"/>
	
</xsl:stylesheet>