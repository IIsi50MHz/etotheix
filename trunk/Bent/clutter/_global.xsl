<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="html" indent="yes"/>
	<xsl:key name="widget" match="@widget" use="."/>
	<xsl:key name="var" match="var" use="@name"/>		
	<xsl:variable name="dingStyle" select="document('ding.style')/style"/>
	
	<!-- IdentityTransform -->
	<xsl:template match="/ | @*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />			
		</xsl:copy>		
	</xsl:template>		
	
	<xsl:template match="head">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />			
			<xsl:apply-templates select="$dingStyle" mode='var'/>				
		</xsl:copy>					
	</xsl:template>
	
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
		<xsl:value-of select="concat('/* ', @name, ' = ', ., $desc, ' */')"/>	
	</xsl:template>
	
	<xsl:template match="@desc" mode="var">		
		<xsl:value-of select="concat(' (', ., ')')"/>		
	</xsl:template>
		
	
	<!--Create standardButton structure
		Transforms mark up like this: 
			<button id="aButtonId" class="standardButton text">{{"Some Button Text"}}</button>
	-->
	<xsl:template match="body">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>			
			<xsl:apply-templates select="key('widget', 'button')[1]" mode='widget'/>
			<xsl:apply-templates select="key('widget', 'buttonx')[1]" mode='widget'/>	
		</xsl:copy>					
	</xsl:template>
	
	<xsl:template match="@widget" mode='widget'/>
	<xsl:template match="@widget[. = 'button']" mode='widget'>
		<script src="xsl.js"></script>
	</xsl:template>
	<xsl:template match="@widget[. = 'buttonx']" mode='widget'>
		<div>widget2</div>
	</xsl:template>
	
	<xsl:template match="button[contains(@class, 'standardButton')]">							
		<div id="{@id}" class="standardButton">
			<div class="standardButtonMiddleLayer"></div>
			<div class="standardButtonTopLayer">					
				<div class="standardButtonTopLayer">
					<div class="standardButtonTopLayerCell"><xsl:apply-templates select="text()"/></div>
				</div>				
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="h1">	
		<h1 style="color: red;">di  ng!!!!</h1>
	</xsl:template>
	
	<!--<xsl:template match="title/text()">	
		<xsl:text>ding!!!!!!</xsl:text>
	</xsl:template>-->
	
	<xsl:template match="@ttid">		
		<xsl:attribute name='tid'><xsl:value-of select='.'/></xsl:attribute>
	</xsl:template>
	<xsl:template match="script_here">		
		
	</xsl:template>
	
	
	
</xsl:stylesheet>


