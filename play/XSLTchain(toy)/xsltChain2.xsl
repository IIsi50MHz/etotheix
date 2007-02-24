<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
 version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:mtsi="http://www.ais-sim.com/mongoose/ns/session-information" 
 xmlns:ui="http://www.ais-sim.com/mongoose/ns/ui-controls"
>
<xsl:template match="ol">	
	
	<xsl:for-each select="li">	
	<xsl:sort select="."/>
		<xsl:copy-of select="."/>
	</xsl:for-each>
	
</xsl:template>
</xsl:stylesheet>