<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:s="structure_stylesheet"	
	xmlns:axsl="axsl"	
	exclude-result-prefixes="s"
>  	
	<xsl:strip-space elements="*"/>
	
	<xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
	<xsl:key name="struc_by_name" match="s:structure_stylesheet/s:struc" use="@name"/>
	<xsl:variable name="s_namsepace_uri" select="namespace-uri(/*)"/>	
	<xsl:variable name="default_ns_is_xhtml" select="'http://www.w3.org/1999/xhtml' = /*/namespace::*[not(name())]"/>	
	
	<!--
		Identity transform (what comes in goes out)
	-->		
	<xsl:template match="@*|node()">
		<xsl:param name="apply"/>
		<xsl:param name="mode_id"/>
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()">
				<xsl:with-param name="apply" select="$apply"/>
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</xsl:copy>		
	</xsl:template>	

	<xsl:template match="s:structure_stylesheet">
		<axsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="s xhtml">
			<xsl:copy-of select="namespace::*|@*"/>			
			<axsl:output method="html" encoding="ISO-8859-1"/>
			<axsl:template match="@*|node()">
				<axsl:copy>			
					<axsl:apply-templates select="@*|node()"/>
				</axsl:copy>		
			</axsl:template>

			<xsl:apply-templates select="s:rule/s:match"/>		
			
			<axsl:template match="processing-instruction('xml-stylesheet')"/>		
		</axsl:stylesheet>
	</xsl:template>

	<xsl:template match="s:match">		
		<!--mode_id used to handle nested rules-->
		<xsl:param name="mode_id"/> 
		<xsl:variable name="new_mode_id" select="generate-id()"/>		

		<!--grab apply elem-->
		<xsl:variable name="apply" select="../s:apply[1]"/>

		<!--grab match selectors-->
		<xsl:variable name="tag_sel" select="s:tag"/>
		<xsl:variable name="attr_sel" select="s:attr"/>
		<xsl:variable name="class_sel" select="s:class"/>		
		<xsl:variable name="id_sel" select="s:id"/>

		<!--grab nested rules-->
		<xsl:variable name="rules" select="../s:rule"/>

		<!--calculate priority for match rule-->		
		<xsl:variable name="selector_priority" select="10000*number(../@important = 'true') + 1000*count($id_sel) + 10*count($attr_sel|$class_sel) + count($tag_sel)"/>

		<!--generate tag match pattern-->
		<xsl:variable name="tag">
			<xsl:choose>
				<xsl:when test="s:tag">
					<xsl:value-of select="$tag_sel/@name"/>
				</xsl:when>
				<xsl:otherwise>*</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--generate id match pattern-->
		<xsl:variable name="id">			
			<xsl:if test="s:id">[@id = '<xsl:value-of select="$id_sel/@name"/>']</xsl:if>			
		</xsl:variable>

		<!--generate class match patterns-->
		<xsl:variable name="classes">
			<xsl:apply-templates select="$class_sel" mode="generate_class_pattern"/>
		</xsl:variable>

		<!--generate attribute match patterns-->
		<xsl:variable name="attrs">
			<xsl:apply-templates select="$attr_sel" mode="generate_attr_pattern"/>
		</xsl:variable>		

		<!--create default xsl template for children if there are nested match rules-->
		<xsl:if test="$mode_id">
			<axsl:template match="node()" mode="{$mode_id}">
				<axsl:apply-templates select="."/>
			</axsl:template>			
		</xsl:if>		

		<!--create an xsl template for each match rule-->		
		<xsl:variable name="pre" select="substring-before($tag, ':')"/>			
		<xsl:variable name="maybe_pre">
			<xsl:if test="not($pre) and $default_ns_is_xhtml">xhtml:</xsl:if>
		</xsl:variable>
		<axsl:template match="{$maybe_pre}{$tag}{$id}{$classes}{$attrs}" priority="{$selector_priority}">
			<xsl:if test="$mode_id">
				<xsl:attribute name="mode">
					<xsl:value-of select="$mode_id"/>
				</xsl:attribute>
			</xsl:if>

			<xsl:variable name="maybe_mode_id">
				<xsl:if test="$rules"><xsl:value-of select="$new_mode_id"/></xsl:if>
			</xsl:variable>

			<xsl:apply-templates select="key('struc_by_name', ../s:apply/@struc)">
				<xsl:with-param name="apply" select="$apply"/>
				<xsl:with-param name="mode_id" select="string($maybe_mode_id)"/>
			</xsl:apply-templates>
		</axsl:template>

		<!--create an xsl template for each nested match rule-->
		<xsl:apply-templates select="../s:rule/s:match">
			<xsl:with-param name="mode_id" select="$new_mode_id"/>
		</xsl:apply-templates>
	</xsl:template>

	<!--generate class patterns-->
	<xsl:template match="s:class" mode="generate_class_pattern">
		<xsl:variable name="class_and_space" select="concat(@name, ' ')"/>		
		<xsl:text>[contains(concat(normalize-space(@class), ' '), '</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text> ')]</xsl:text>
	</xsl:template>

	<!--generate attr patterns-->
	<xsl:template match="s:attr" mode="generate_attr_pattern">			
		<xsl:text>[@</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:if test="@val">
			<xsl:text> = '</xsl:text><xsl:value-of select="@val"/><xsl:text>'</xsl:text>
		</xsl:if>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<!--struc-->
	<xsl:template match="s:struc">		
		<xsl:param name="apply"/>
		<xsl:param name="mode_id"/>
		<xsl:apply-templates select="node()">
			<xsl:with-param name="apply" select="$apply"/>
			<xsl:with-param name="mode_id" select="$mode_id"/>
		</xsl:apply-templates>
	</xsl:template>

	<!--elem-->
	<xsl:template match="s:elem">
		<xsl:param name="apply"/>
		<xsl:param name="mode_id"/>		

		<xsl:variable name="elem_tag_name" select="s:tag/@name"/>
		<xsl:variable name="apply_tag_name" select="$apply/s:tag/@name"/>		

		<!--create tag name-->
		<xsl:variable name="tag">
			<xsl:choose>
				<xsl:when test="$apply_tag_name">
					<xsl:value-of select="$apply_tag_name"/>
				</xsl:when>
				<xsl:when test="$elem_tag_name">
					<xsl:value-of select="$elem_tag_name"/>
				</xsl:when>
				<xsl:otherwise>{name()}</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<axsl:element name="{$tag}">
			<!--generate attributes for current node-->
			<axsl:apply-templates select="@*"/>
			<!--generate attributes for elem tag (overrides attributes for current node)-->
			<xsl:apply-templates select="s:attr"/>			
			<!--generate attributes for apply tag (overrides attributes for current node and elem tag)-->
			<xsl:apply-templates select="$apply/s:attr"/>

			<!--gather classes to add, eliminating duplicates-->
			<xsl:variable name="elem_class_names" select="s:class/@name"/>
			<xsl:variable name="apply_class_names" select="$apply/s:class/@name"/>		
			<xsl:variable name="added_classes" select="$elem_class_names|$apply_class_names[not(. = $elem_class_names)]"/>	
			
			<!--generate code to add classes if there are any-->
			<xsl:if test="$added_classes">
				<axsl:variable name="orig_classes" select="concat(normalize-space(@class), ' ')"/>
				<axsl:variable name="classes">
					<axsl:value-of select="$orig_classes"/>
					<xsl:apply-templates select="$added_classes"/>
				</axsl:variable>			
				<axsl:variable name="trimmed_classes" select="normalize-space($classes)"/>
				<axsl:if test="$trimmed_classes">
					<axsl:attribute name="class"><axsl:value-of select="$trimmed_classes"/></axsl:attribute>
				</axsl:if>
			</xsl:if>
			
			<!--reproduce contents of elem tag-->
			<xsl:apply-templates select="node()[namespace-uri() != $s_namsepace_uri]">
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>

			<!--continue processing if elem is empty (treat <xsl:elem/> just like <xsl:elem><xsl:inner/></xsl:elem>)-->
			<xsl:if test="not(node())">
				<axsl:apply-templates select="node()">
					<xsl:if test="$mode_id">
						<xsl:attribute name="mode">
							<xsl:value-of select="$mode_id"/>
						</xsl:attribute>
					</xsl:if>
				</axsl:apply-templates>
			</xsl:if>
		</axsl:element>
	</xsl:template>

	<!--add attributes-->
	<xsl:template match="s:elem/s:attr|s:apply/s:attr">	
		<axsl:attribute name="{@name}">
			<xsl:value-of select="@val"/>
		</axsl:attribute>
	</xsl:template>
	
	<!--add id-->
	<xsl:template match="s:elem/s:id|s:apply/s:id">	
		<axsl:attribute name="id">
			<xsl:value-of select="@name"/>
		</axsl:attribute>
	</xsl:template>
	
	<!--add classes-->
	<xsl:template match="s:elem/s:class/@name|s:apply/s:class/@name">	
		<xsl:variable name="class" select="concat(., ' ')"/>
		<axsl:if test="not(contains($orig_classes, '{$class}'))"><xsl:value-of select="$class"/></axsl:if>
	</xsl:template>

	<!--inner-->
	<xsl:template match="s:inner">
		<xsl:param name="mode_id"/>
		<axsl:apply-templates select="node()">
			<xsl:if test="$mode_id">
				<xsl:attribute name="mode">
					<xsl:value-of select="$mode_id"/>
				</xsl:attribute>
			</xsl:if>
		</axsl:apply-templates>
	</xsl:template>	

</xsl:stylesheet>