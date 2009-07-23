<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:output method="html" indent="no"/>
	<!--get rid of useless text nodes-->
	<!--NOTE: may not want to strip space at first (or ever?). This should make it easier to spot where markup needs cleanup-->
	<!--<xsl:strip-space elements="*"/>	-->
	<!--list of files to grab strings from-->
	<xsl:variable name="file_names" select="document('file_list.xml')/files/file"/>	
	<!--grab all files in list-->
	<xsl:variable name="files" select="document($file_names)"/>			
		
	<xsl:template match="/">
		<translations>			
			<!--generate strings and other info for each file-->
			<xsl:apply-templates select="$file_names" mode="load_file"/>				
		</translations>
	</xsl:template>	
	
	<!--generate strings and other info for each file-->
	<xsl:template match="file" mode="load_file">
		<!--grab all the text nodes for the current file; pass the file name along-->
		<xsl:apply-templates select="document(.)//text()">
			<xsl:with-param name="file_name" select="."/>
		</xsl:apply-templates>		
	</xsl:template>			
	
	<!--grab all text nodes (exceptions below)-->
	<xsl:template match="text()[normalize-space()!='']">
		<xsl:param name="file_name"/>
		<translate>
			<file_name><xsl:value-of select="$file_name"/></file_name>
			<from><xsl:value-of select="."/></from>
			<to></to>
		</translate>
	</xsl:template>
	
	<!--don't grab these text nodes (stuff in head, script elements, etc.)-->
	<xsl:template match="text()[ancestor::head|ancestor::script|ancestor::xsl:attribute]"/>
	
</xsl:stylesheet>