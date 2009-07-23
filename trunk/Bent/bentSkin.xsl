<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<!--@skin
		NOTE: leave at least one space at the end of the class list for each template (new line is fine too)
	-->
	<!--@iclass - if defined properly in a style sheet, any classes in an i
		class will take precedence over and regular classes (acts kind of like !important)
	-->
	<!--@skin - just use value of skin attrbute by default-->
	<xsl:template match="@skin" mode="generate_class"><xsl:value-of select="concat(., ' ')"/></xsl:template>
	<!--skin1-->
	<xsl:template match="@skin[. = 'skin1']" mode="generate_class">t-bC p-cA p-bcA p-bgcA g-mE f-ffA f-b </xsl:template>
	<!--skin2-->
	<xsl:template match="@skin[. = 'skin2']" mode="generate_class">t-bC p-cA g-pE </xsl:template>
</xsl:stylesheet>