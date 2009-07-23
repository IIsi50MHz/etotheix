<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="html" indent="yes"/>
	<xsl:key name="widget" match="*[@widget]" use="@widget"/>	
	<xsl:variable name="widget_doc_widgets" select="document('bentWidgets.xml')/widgets/widget"/>		
	<!--grab one of each type of widget (for script loading)-->
	<xsl:variable name="first_of_each_widget_type" select="//*[@widget][generate-id() = generate-id(key('widget', @widget))]"/>
	
	<xsl:template match="body">		
		<xsl:copy>		
			<xsl:apply-templates select="@*|node()"/>			
			<xsl:apply-templates select="$first_of_each_widget_type" mode="inject_widget_script"/>						
		</xsl:copy>					
	</xsl:template>
	
	<xsl:template match="*[@widget]">		
		<xsl:variable name="widget_name" select="@widget"/>			
		<xsl:copy>
			<xsl:apply-templates select="@*"/>			
			<xsl:apply-templates select="$widget_doc_widgets" mode="add_widget">
				<xsl:with-param name="widget_name" select="$widget_name"/>
			</xsl:apply-templates>		
			<xsl:apply-templates select="node()"/>
		</xsl:copy>	
	</xsl:template>	
	
	<xsl:template match="widget" mode="add_widget">		
		<xsl:param name="widget_name"/>
		<xsl:apply-templates select="key('widget', $widget_name)" mode="add_widget"/>
	</xsl:template>
	
	<xsl:template match="widget" mode="add_widget">		
		<xsl:apply-templates select="@script|node()"/>
	</xsl:template>	
	
	<xsl:template match="*[@widget]" mode="inject_widget_script">	
		<xsl:variable name="widget_name" select="@widget"/>
		<xsl:apply-templates select="$widget_doc_widgets[@name = $widget_name]/@script" mode="inject_widget_script"/>		
	</xsl:template>
	
	<xsl:template match="@script" mode="inject_widget_script">				
		<script src="{.}"></script>
	</xsl:template>
	
</xsl:stylesheet>