<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:s="structure-stylesheet"	
	xmlns:axsl="axsl"	
	exclude-result-prefixes="s"
>
	<xsl:output indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
	<xsl:key name="struc_by_name" match="s:structure-stylesheet/s:struc" use="@name"/>
	
	<!--
		Identity transform (what comes in goes out)
	-->		
	<xsl:template match="@*|node()">		
		<xsl:param name="mode_id"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()">
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>	

	<!--create stylesheet-->
	<xsl:template match="s:structure-stylesheet">
		<axsl:stylesheet version="1.0" exclude-result-prefixes="s">
			<xsl:copy-of select="namespace::*|@*"/>			
			<axsl:output method="html" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
			<axsl:strip-space elements="*"/>
			
			<!--create code for altering document structure-->
			<axsl:template match="@*|node()">
				<axsl:copy>			
					<axsl:apply-templates select="@*|node()"/>
				</axsl:copy>		
			</axsl:template>

			<xsl:apply-templates select="@* | node()"/>		

			<axsl:template match="processing-instruction('xml-stylesheet')"/>		
		</axsl:stylesheet>
	</xsl:template>

	<!--Replace s namespace with axsl.-->
	<xsl:template match="s:* | xsl:*">		
		<xsl:param name="mode_id"/>		
		<xsl:element name="axsl:{local-name()}" namespace="http://www.w3.org/1999/XSL/Transform">
			<xsl:apply-templates select="@* | node()">
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<!--Use other structure stylesheets-->
	<xsl:template match="s:use">
		<xsl:comment></xsl:comment>
		<xsl:comment>[START] s:use <xsl:value-of select="@href"/></xsl:comment>
		<xsl:comment></xsl:comment>
		<xsl:apply-templates select="document(@href)/*/*"/>
		<xsl:comment></xsl:comment>
		<xsl:comment>[END] s:use Using <xsl:value-of select="@href"/></xsl:comment>
		<xsl:comment></xsl:comment>
	</xsl:template>
	
	<!--Change s:this to xsl:element-->
	<xsl:template match="s:this">
		<xsl:param name="mode_id"/>
		<xsl:variable name="tag">
			<xsl:choose>
				<xsl:when test="s:tag">
					<xsl:value-of select="s:tag/@name"/>
				</xsl:when>
				<xsl:otherwise>{name()}</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:comment></xsl:comment>
		<xsl:comment>s:this</xsl:comment>		
		<axsl:element name="{$tag}">
			<!--gather removed attributes-->
			<xsl:variable name="removed_attr">
				<xsl:for-each select="s:remove-attr">
					<xsl:value-of select="concat(@name, ' ')"/>
				</xsl:for-each>
			</xsl:variable>		

			<!--COMPILED XSL: only add attributes that are not removed-->
			<axsl:for-each select="@*[not(contains('{$removed_attr}', concat(name(), ' ')))]">
				<axsl:attribute name="{{name()}}">
					<axsl:value-of select="."/>
				</axsl:attribute>	
			</axsl:for-each>						

			<!--keep going...-->
			<xsl:apply-templates select="@* | node()">
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:element>
	</xsl:template>	

	<!--Pull s:this attributes out; make them elements.-->
	<xsl:template match="s:this/@*">
		<xsl:comment></xsl:comment>
		<xsl:comment>s:this atribute</xsl:comment>
		<axsl:attribute name="{name()}">
			<xsl:value-of select="."/>
		</axsl:attribute>
	</xsl:template>

	<!--Remove these tags and attributes-->
	<xsl:template match="s:tag | s:remove-attr | s:struc | @struc"/>	

	<!--Replace class function in match and select attributes with valid xpath expression-->
	<xsl:template name="replace_class">
		<xsl:param name="match_attr" select="normalize-space(.)"/>				
		<xsl:choose>					
			<xsl:when test="contains($match_attr, 'class(')">
				<xsl:variable name="class" select="substring-before(substring-after($match_attr, 'class('), ')')"/>
				<xsl:variable name="quote_char" select="substring($class, 1, 1)"/>
				<xsl:variable name="no_quotes_class" select="translate($class, $quote_char, '')"/>
				<xsl:variable name="before_class" select="substring-before($match_attr, 'class(')"/>		
				<xsl:variable name="after_class" select="substring-after($match_attr, concat('class(', $class, ')'))"/>		
				<xsl:variable name="class_selector">
					<xsl:text>contains(concat(normalize-space(@class), ' '), </xsl:text>					
					<xsl:value-of select="concat($quote_char, $no_quotes_class, ' ', $quote_char)"/>
					<xsl:text>)</xsl:text>
				</xsl:variable>
				<xsl:call-template name="replace_class">
					<xsl:with-param name="match_attr" select="concat($before_class, $class_selector, $after_class)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$match_attr"/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<xsl:template match="@match | @select">
		<xsl:attribute name="{name()}">
			<xsl:call-template name="replace_class"/>				
		</xsl:attribute>
	</xsl:template>	

	<xsl:template match="s:rule">		
		<!--mode_id used to handle nested rules-->
		<xsl:param name="mode_id"/> 
		<xsl:variable name="new_mode_id" select="generate-id()"/>	

		<!--grab nested rules-->
		<xsl:variable name="rules" select="s:rule"/>		

		<!--create top level template-->
		<xsl:choose>
			<xsl:when test="not($mode_id)">
				<xsl:comment></xsl:comment>
				<xsl:comment>**************************************************************************************</xsl:comment>
				<xsl:comment>Top level template for s:rule</xsl:comment>
				<xsl:comment>   struc: <xsl:value-of select="@struc"/></xsl:comment>				
				<xsl:comment>**************************************************************************************</xsl:comment>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment></xsl:comment>
				<xsl:comment>******************************************</xsl:comment>
				<xsl:comment>Nested s:rule</xsl:comment>
				<xsl:comment>   struc: <xsl:value-of select="@struc"/></xsl:comment>
				<xsl:comment>   mode: <xsl:value-of select="$mode_id"/></xsl:comment>							
				<xsl:comment>******************************************</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
		<axsl:template>			
			<xsl:apply-templates select="@*"/>
			<xsl:if test="$mode_id">
				<xsl:attribute name="mode">
					<xsl:value-of select="$mode_id"/>
				</xsl:attribute>
			</xsl:if>			

			<!--generate stucture for rule-->
			<xsl:apply-templates select="key('struc_by_name', @struc)" mode="copy_struc">				
				<xsl:with-param name="mode_id" select="string($new_mode_id)"/>
			</xsl:apply-templates>
		</axsl:template>		

		<!--create default xsl template for children if there are nested match rules-->
		<xsl:if test="$rules">
			<xsl:comment></xsl:comment>
			<xsl:comment>**************************************************</xsl:comment>
			<xsl:comment>Auto generated default nested rule</xsl:comment>	
			<xsl:comment>   mode: <xsl:value-of select="$new_mode_id"/></xsl:comment>	
			<xsl:comment>**************************************************</xsl:comment>
			<axsl:template match="node()" mode="{$new_mode_id}">
				<axsl:apply-templates select="."/>
			</axsl:template>			
		</xsl:if>	

		<!--create an xsl template for each nested rule-->
		<xsl:apply-templates select="$rules">
			<xsl:with-param name="mode_id" select="$new_mode_id"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="node()|@*" mode="copy">		
		<xsl:copy>				
			<xsl:apply-templates select="node()[not(self::s:*)]|@*" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<!--struc-->
	<xsl:template match="s:struc" mode="copy_struc">		
		<xsl:param name="mode_id"/>		
		<xsl:apply-templates select="node()">			
			<xsl:with-param name="mode_id" select="$mode_id"/>
		</xsl:apply-templates>
	</xsl:template>	

	<!--apply-rules becomes apply-templates (with some special handling)-->
	<xsl:template match="s:apply-rules">
		<xsl:param name="mode_id"/>
		<xsl:comment></xsl:comment>
		<xsl:comment>s:apply-rules</xsl:comment>
		<axsl:apply-templates>
			<xsl:apply-templates select="@*"/>
			<xsl:if test="$mode_id">
				<xsl:attribute name="mode">
					<xsl:value-of select="$mode_id"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()">
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:apply-templates>
	</xsl:template>

	<!--
		aliases
	-->

	<!--s:inline-struc == xsl:for-each-->
	<xsl:template match="s:inline-struc">		
		<xsl:param name="mode_id"/>		
		<xsl:comment></xsl:comment>
		<xsl:comment>s:inline-struc</xsl:comment>
		<axsl:for-each>
			<xsl:apply-templates select="@* | node()">			
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:for-each>
	</xsl:template>

	<!--s:var == xsl:variable-->
	<xsl:template match="s:var">
		<xsl:param name="mode_id"/>		
		<xsl:comment>s:var</xsl:comment>
		<axsl:variable>
			<xsl:apply-templates select="@* | node()">			
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:variable>
	</xsl:template>

	<!--s:val == xsl:value-of-->
	<xsl:template match="s:val">
		<xsl:param name="mode_id"/>			
		<xsl:comment>s:val</xsl:comment>		
		<axsl:value-of>
			<xsl:apply-templates select="@* | node()">			
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:value-of>
	</xsl:template>

</xsl:stylesheet>