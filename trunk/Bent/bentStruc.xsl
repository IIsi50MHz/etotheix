<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<!--@struc-->
	<!--@struc - don't generate any classes by default-->
	<xsl:template match="@struc" mode="generate_class"/>	
	<!--area - display:table always-->
	<xsl:template match="@struc[.='area']" mode="generate_class">area s-pr s-fs s-dt </xsl:template>	
	<!--row - display:table-row if inside @struc=area, otherwise block-->
	<xsl:template match="@struc[.='row']" mode="generate_class">row s-pr </xsl:template>	
	<!--col - display:table-cell if inside @struc=area, otherwise block-->	
	<xsl:template match="@struc[.='col']" mode="generate_class">col s-pr s-fs s-h100 </xsl:template> 
	
	<!--@dim-->	
	<!--@dim - don't generate any classes by default-->
	<xsl:template match="@dim"/>
	<xsl:template match="@dim[.='min']" mode="generate_class">s-fs </xsl:template>
	<xsl:template match="@dim[.='min'][../@struc='col']" mode="generate_class">minCol </xsl:template>
	<xsl:template match="@dim[.='min'][../@struc='row']" mode="generate_class">minRow </xsl:template>	
	<xsl:template match="@dim[.='max']" mode="generate_class">max </xsl:template>		
	<xsl:template match="@dim[.='max'][../@struc='area']" mode="generate_class">s-w100 s-h100 </xsl:template>
	<xsl:template match="@dim[.='max'][../@struc='col']" mode="generate_class">s-w100 </xsl:template>	
	<xsl:template match="@dim[.='max'][../@struc='row']" mode="generate_class">s-h100 </xsl:template>		
	
</xsl:stylesheet>