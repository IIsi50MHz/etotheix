<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:output method="html" indent="yes"/>
	
	<xsl:include href="bentSkin.xsl"/>
	<xsl:include href="bentStruc.xsl"/>
	<xsl:include href="bentStyle.xsl"/>
	<!--<xsl:include href="bentExamples.xsl"/>-->
	<xsl:include href="bentWidget.xsl"/>	
	
	<!--MAIN TEMPLATES-->
	<xsl:template match="/|@*|node()">	
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>		
	</xsl:template>	
	
	<xsl:template match="*[@class|@skin|@struc|@dim]">	
		<xsl:copy>			
			<xsl:apply-templates select="." mode="generate_class"/>			
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>		
	</xsl:template>		
	
	<!--GENERATE CLASS TEMPLATES
		Classes are generated from the @skin, @struc, and @dim attributes.		
		
		The idea is to make it easy to extend existing classes without having to add them directly 
		to every element of the markup. This should keep both the markup and the css clean. This should
		also make it really easy to change stuff.
	-->
	
	<xsl:template match="@class"/>	
	<xsl:template match="*[@class|@skin|@struc|@dim]" mode="generate_class">		
		<xsl:variable name="new_classes">
			<xsl:apply-templates select="@skin|@struc|@dim" mode="generate_class"/>		
		</xsl:variable>		
		<xsl:attribute name="class">
			<xsl:value-of select="normalize-space(concat(@class, ' ', $new_classes))"/>
		</xsl:attribute>
	</xsl:template>
	
	<!--@dim TEMPLATES-->
	<xsl:template match="@style"/>
	<xsl:template match="@dim[. != 'min' and . != 'max']">				
		<xsl:attribute name="style">				
			<xsl:value-of select="."/>
		</xsl:attribute>				
		<xsl:copy>		
			<xsl:apply-templates select="@*|node()"/>										
		</xsl:copy>
	</xsl:template>	
	
	<!--@struc TEMPLATES		
		- comination of structural markup and css
		- css inclues things like width, height, display, overflow, etc.
		- xslt may decorate or modify markup to get desired structural behavior
	-->		
	
	<!--Add a relatively positioned element inside a @struc='col' if it is displayed as table-cell.
		NOTE: This fixes a problem in Firefox where stuff in a table cell can't be can't be positioned properly
		in relation to the cell even when the cell is position:relative
	-->
	<xsl:template match="		
		b[@struc='area']/b[@struc='col' or @struc='row'][not(b)]|
		b[@struc='area']/b[@struc='col' or @struc='row']/b[not(b)]		
	">
		<xsl:copy>		
			<xsl:apply-templates select="." mode="generate_class"/>		
			<xsl:apply-templates select="@*"/>
			<b class="s-h100 s-pr" gen="true">
				<xsl:apply-templates select="node()"/>	
			</b>
		</xsl:copy>	
	</xsl:template>	
</xsl:stylesheet>


