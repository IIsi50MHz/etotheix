<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:ui="http://www.ais-sim.com/mongoose/ns/ui-controls"
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="html" indent="yes"/>	
	<xsl:param name="contentType" />
	<xsl:key name="cat" match="ui:categorized_listbox/ui:entry/ui:category" use="."/>
	<!-- VARIABLES -->		
	
	<!-- MAIN TEMPLATE -->
	<xsl:template match="/ui:categorized_listbox">		
		<html>
			<head>
				<title>HLEO!</title>
			</head>
			
			<body>
				<!-- make a list of unique categories, but leave out all subcategories -->
				<xsl:for-each select="ui:entry/ui:category[generate-id(.)=generate-id(key('cat', .))]">
				<xsl:sort/>						
					<xsl:if test="not(contains(., '/'))">	
						<p>							
							<xsl:value-of select="."/>							
						</p>
					</xsl:if>					
				</xsl:for-each>
				<script type="text/javascript" src="../js/jquery-latest.js"></script>
				<script type="text/javascript">
					jQuery("p").append("[ding!!]")
				</script>
			</body>
		</html>
	</xsl:template>

	<!-- TEMPLATES USED BY MAIN TEMPLATE -->
	<!-- create text list items -->
	<xsl:template name="createList">	
	
	</xsl:template>	
</xsl:stylesheet>