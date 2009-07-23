<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	
	xmlns:html="http://www.w3.org/1999/xhtml"

	xmlns:exsl="http://exslt.org/common"
	xmlns:math="http://exslt.org/math"
	xmlns:regexp="http://exslt.org/regular-expressions"
	xmlns:set="http://exslt.org/sets"
	xmlns:str="http://exslt.org/strings"	
	exclude-result-prefixes="exsl math regexp set str"
>
	<xsl:output method="html" indent="yes"/>

	<!--MAIN TEMPLATES-->
	<xsl:template match="/">	
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>										
		</xsl:copy>		
	</xsl:template>		

	<xsl:template match="@*">		
		<xsl:copy>		
			<xsl:apply-templates select="@* | node()"/>										
		</xsl:copy>		
	</xsl:template>	

	<xsl:template match="node()">	
		<xsl:copy>		
			<xsl:apply-templates select="@* | node()"/>										
		</xsl:copy>		
	</xsl:template>	

	<!--
		EX: Modify/expand the values of these attributes 
		NOTE: The modified value gets added to the class attribute in the main tempate
		
		The idea is to make it easy to extend existing classes without having to add them directly 
		to every element of the markup. This should keep both the markup and the css clean. This should
		also make it really easy to change stuff.
	-->
	<xsl:template match="@class"/>
	<xsl:template match="@thing | @structure">		
		<xsl:variable name="parent_node" select=".."/>
		<xsl:variable name="class_classes" select="concat($parent_node/@class, ' ')"/>				
		<xsl:variable name="thing_classes">
			<xsl:apply-templates select="$parent_node/@thing" mode="generate_class"/>
		</xsl:variable>
		<xsl:variable name="structure_classes">
			<xsl:apply-templates select="$parent_node/@structure" mode="generate_class"/>
		</xsl:variable>
		
		<xsl:attribute name="class">				
			<xsl:value-of select="normalize-space(concat($class_classes, ' ', $structure_classes, $thing_classes))"/>
		</xsl:attribute>
		<xsl:copy>		
			<xsl:apply-templates select="@* | node()"/>										
		</xsl:copy>	
	</xsl:template>	
	
	<!--SKINS
		- pure css 
		- includes things like background, border, color, margin, padding, etc.
		- don't use skin attribute with thing attribute
	-->
	<xsl:template match="@skin" mode="generate_class">
		<xsl:value-of select="."/>
	</xsl:template>
	<!--skin1-->
	<xsl:variable name="skin1_classes">skin1</xsl:variable>	
	<xsl:template match="@skin[. = 'skin1']" mode="generate_class">
		<xsl:value-of select="$skin1_classes"/>
	</xsl:template>

	<!--STRUCTURES		
		- comination of structural markup and css
		- css inclues things like width, height, display, overflow, etc.
		- xslt may decorate or modify markup to get desired structural behavior
		- don't use structure attribute with thing attribute
	-->	
	<xsl:template match="@structure" mode="generate_class">
		<xsl:value-of select="."/>
	</xsl:template>
	<!--structure1-->
	<xsl:variable name="structure1_classes">shrink_x shrink_y</xsl:variable>	
	<xsl:template match="@structure[. = 'structure1']" mode="generate_class">
		<xsl:value-of select="$structure1_classes"/>
	</xsl:template>

	<!--thingS
		- combines structure and skin into one package
		- don't use thing attribute use with skin or structure attributes
	-->	
	<xsl:template match="@thing[. = 'dialog1']" mode="generate_class">
		<xsl:value-of select="concat('dialog ', $structure1_classes, ' ', $skin1_classes)"/>		
	</xsl:template>
	<xsl:template match="@thing[. = 'hd1']" mode="generate_class">hd shrink_y skin1</xsl:template>
	<xsl:template match="@thing[. = 'bd1']" mode="generate_class">bd shrink_y skin1</xsl:template>
	<xsl:template match="@thing[. = 'ft1']" mode="generate_class">ft shrink_y skin1</xsl:template>

	<!--dialog wrapper (centers dialogs)-->		
	<xsl:template match="*[@id='dialogs']">
		<table style="position:absolute; top:0; width:100%; height:100%">	
			<!--EX: copy attributes of match to table element-->
			<xsl:apply-templates select="@*"/> 			
			<tr>			
				<td style="vertical-align:middle; text-align:center">					
					<!--EX: copy nodes (but not attributes!) of match to td element-->
					<xsl:apply-templates select="node()"/>
				</td>
			</tr>
		</table>					
	</xsl:template>

	<!--structure1 templates-->
	<!--none-->

	<!--structure2 templates-->
	<xsl:template match="		
		*[@structure='structure2']		
	">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<table>	
				<xsl:apply-templates select="node()"/>			
			</table>
		</xsl:copy>		
	</xsl:template>

	<xsl:template match="
		*[@structure='structure2']/*[@thing='hd' or @thing='bd' or @thing='ft']		
	">
		<tr>			
			<td>	
				<xsl:apply-templates select="@*"/>
				<xsl:copy>
					<!--EX: change the tag for this thing into a td-->
					<xsl:apply-templates select="node()"/>			
				</xsl:copy>
			</td>
		</tr>
	</xsl:template>

	<!--<xsl:template match="@class[regexp:match(., '\area\b', 'g')]">		
		<xsl:apply-templates select="@* | node()"/>
	</xsl:template>	-->
</xsl:stylesheet>


