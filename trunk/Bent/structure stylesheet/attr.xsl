<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:output method="html" indent="yes"/>	
	<!--NODE MANIPULATION EXAMPLES-->
	<xsl:template match="@*|node()">
		<xsl:copy>	
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="blah1">
				(<xsl:value-of select="'xxx'"/>)
			</xsl:attribute>
			<xsl:attribute name="blah">dong</xsl:attribute>
			<xsl:attribute name="names">XXX</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>		
	</xsl:template>
</xsl:stylesheet>