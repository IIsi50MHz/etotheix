<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
 version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:mtsi="http://www.ais-sim.com/mongoose/ns/session-information" 
 xmlns:ui="http://www.ais-sim.com/mongoose/ns/ui-controls"
>
<!-- 
This should be changed, if possible, so that it uses the html created for the "all" view instead of the loaded xml file.
That way, any changed made to the list will... be... reflected... damn... Nevermind.
-->
<xsl:template match="/">	
	<ol id="blah"><!--Should move this ol tag out and make it a perminent emelement--> 
		<xsl:for-each select="ol/li">	
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</ol>
</xsl:template>
</xsl:stylesheet>