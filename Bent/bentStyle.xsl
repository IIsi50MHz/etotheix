<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<!--With this stylesheet, we can add variables to a css stylesheet-->
	
	<xsl:output method="html" indent="yes"/>
	<xsl:key name="var" match="var" use="@name"/>		
	<xsl:variable name="mainStyle" select="document('bent.style')/style"/>
	
	<!--TEMPLATE FOR INJECTING STYLE INTO HTML FILE BEING PROCESSED-->	
	<xsl:template match="head">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />			
			<xsl:apply-templates select="$mainStyle" mode='var'/>				
		</xsl:copy>					
	</xsl:template>
	
	<!--TEMPLATES FOR ADDING VARAIBLES TO A CSS STYLESHEET-->
	<xsl:template match="style" mode="var">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="var"/>							
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="val" mode="var">		
		<xsl:variable name="desc">
			<xsl:apply-templates select="key('var', @name)/@desc" mode="var"/>
		</xsl:variable>
		<xsl:variable name="val">
			<xsl:value-of select="key('var', @name)"/>
		</xsl:variable>		
		<xsl:value-of select="concat($val, ' /* ', @name, $desc, ' */')"/>	
	</xsl:template>
	
	<xsl:template match="var" mode="var">
		<xsl:variable name="desc">
			<xsl:apply-templates select="@desc" mode="var"/>
		</xsl:variable>		
		<xsl:value-of select="concat(@name, ' = ', ., $desc)"/>	
	</xsl:template>
	
	<xsl:template match="@desc" mode="var">		
		<xsl:value-of select="concat(' (', ., ')')"/>		
	</xsl:template>	
</xsl:stylesheet>


