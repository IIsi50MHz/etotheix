<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="html" indent="yes"/>		

	<!--grab translation file-->
	<xsl:variable name="translations" select="document('translate.xml')/translations"/>

	<!--grab scripts in head and body-->
	<xsl:variable name="scripts" select="/html/head/script[@src]|/html/body/script[@src]"/>
	<xsl:variable name="path_to_scripts">../js/</xsl:variable>

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
		<xsl:variable name="translation" select="key('translate', $text)"/>
		<xsl:choose>
			<xsl:when test="$translation != ''">
				<xsl:value-of select="$translation"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>	
		</xsl:choose>		
	</xsl:template>	

	<!--oh, and don't translate these text nodes (stuff in head, script elements, etc.)-->
	<xsl:template match="text()[ancestor::head|ancestor::script|ancestor::xsl:attribute]">	
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>	
	</xsl:template>	

	<!--generate js strings-->
	<xsl:template match="head">
		<xsl:copy>				
			<script>
				<xsl:text>var js_strings = {};
				</xsl:text> 
				<xsl:text>parent.window.js_strings = js_strings;
				</xsl:text>
				<xsl:apply-templates select="$scripts" mode="js_strings"/>			
			</script>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>		
	</xsl:template>	

	<xsl:template match="script" mode="js_strings">			
		<xsl:variable name="js_string_file_name" select="substring-after(concat(substring-before(@src, '.js'), '.xml'), $path_to_scripts)"/>
		<xsl:variable name="js_string_doc" select="document($js_string_file_name)"/>
		<xsl:variable name="js_strings_key" select="$js_string_doc/js_strings/@key"/>
		<xsl:variable name="js_strings" select="$js_string_doc/js_strings/js_string"/>			
		<xsl:apply-templates select="$js_strings" mode="js_strings"/>
	</xsl:template>	

	<xsl:template match="js_string" mode="js_strings">		
		<xsl:text>js_strings["</xsl:text>
		<xsl:value-of select="@key"/>
		<xsl:text>"] = "</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>";
		</xsl:text>
	</xsl:template>
</xsl:stylesheet>


