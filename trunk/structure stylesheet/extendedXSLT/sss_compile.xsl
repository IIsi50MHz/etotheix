<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:regexp="http://exslt.org/regular-expressions"


	xmlns:s="structure-stylesheet"	
	xmlns:axsl="axsl"	
	exclude-result-prefixes="s"
	extension-element-prefixes="regexp"
>
	<xsl:output indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
	<xsl:key name="struc_by_name" match="s:struc" use="@name"/>
	<xsl:variable name="uses" select="//s:use"/>
	<xsl:variable name="master_doc" select="/*"/>

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
		<xsl:comment/>
		<xsl:comment>[START] s:use <xsl:value-of select="@href"/>
		</xsl:comment>
		<xsl:comment/>
		<xsl:apply-templates select="document(@href)/*/*"/>
		<xsl:comment/>
		<xsl:comment>[END] s:use Using <xsl:value-of select="@href"/>
		</xsl:comment>
		<xsl:comment/>
	</xsl:template>

	<!--Change s:this to xsl:element-->
	<xsl:template match="s:this">
		<xsl:param name="mode_id"/>
		<xsl:variable name="tag" select="s:tag/@name"/>		
		<xsl:variable name="inner">
			<!--gather removed attributes-->
			<xsl:variable name="removed_attr">
				<xsl:for-each select="s:remove-attr">
					<xsl:value-of select="concat(@name, ' ')"/>
				</xsl:for-each>
			</xsl:variable>		

			<!--COMPILED XSL: only add attributes that are not removed-->
			<xsl:if test="normalize-space($removed_attr) != ''">
				<axsl:for-each select="@*[not(contains('{$removed_attr}', concat(name(), ' ')))]">
					<axsl:attribute name="{{name()}}">
						<axsl:value-of select="."/>
					</axsl:attribute>	
				</axsl:for-each>			
			</xsl:if>

			<!--keep going...-->
			<xsl:apply-templates select="@* | node()">
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:comment/>
		<xsl:comment>s:this</xsl:comment>

		<xsl:choose>
			<xsl:when test="$tag">				
				<axsl:element name="{$tag}">
					<xsl:copy-of select="$inner"/>
				</axsl:element>				
			</xsl:when>
			<xsl:otherwise>
				<axsl:copy>
					<xsl:copy-of select="$inner"/>
				</axsl:copy>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>	

	<!--Pull s:this attributes out; make them elements.-->
	<xsl:template match="s:this/@*">
		<xsl:comment/>
		<xsl:comment>s:this attribute</xsl:comment>
		<axsl:attribute name="{name()}">
			<xsl:value-of select="."/>
		</axsl:attribute>
	</xsl:template>

	<!--Remove these tags and attributes-->
	<xsl:template match="s:tag | s:remove-attr | s:structure-stylesheet/s:struc | @struc"/>	

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

	<!--Replace css function in match and select attributes with valid xpath expression-->
	<xsl:template name="replace_css">
		<xsl:param name="match_attr" select="normalize-space(.)"/>				
		<xsl:choose>					
			<xsl:when test="contains($match_attr, 'css(')">
				<!--<xsl:text>{{helo}}</xsl:text>-->
				<xsl:variable name="css" select="substring-before(substring-after($match_attr, 'css('), ')')"/>								
				<xsl:variable name="before_css" select="substring-before($match_attr, 'css(')"/>		
				<xsl:variable name="after_css" select="substring-after($match_attr, concat('css(', $css, ')'))"/>		
				<!--<xsl:value-of select="concat('{{', $css, '}}')"/>-->
				<xsl:variable name="css_selector">
					<xsl:call-template name="css_selector_to_xpath">
						<xsl:with-param name="orig_string" select="$css"/>
					</xsl:call-template>
				</xsl:variable>
				<!--<xsl:value-of select="concat('{{', $css_selector, '}}')"/>-->
				<xsl:call-template name="replace_css">
					<xsl:with-param name="match_attr" select="concat($before_css, $css_selector, $after_css)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!--<xsl:text>{{helo2}}</xsl:text>-->
				<xsl:value-of select="$match_attr"/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<!--ding.dong.king#kong[blah][ask='asdf'] .blah	
	..#[[
	
	translate('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOP-_=]   '"')
	
	ding|dong|king|kong|blah}|ask="asdf"}
	
	ding[contains(concat(normalize-space(@class), ' '), 'dong[@id='kong[@blah][@ask="asdf"]//[.blah
	
	ding[contains(concat(normalize-space(@class), ' '), 'dong')][contains(concat(normalize-space(@class), ' '), 'king')][@id='kong'][@blah][@ask="asdf"]
	
	
	ding!dong!king!kong!blah!ask="abc ding" !blah-->
	
	<xsl:template name="css_selector_to_xpath">
		<!--build up xpath-->
		<xsl:param name="xpath" select="''"/>
		<!--ding.dong.king#kong[blah][ask='asdf']-->
		<!--.dong.king#kong[blah][ask='asdf']-->
		<xsl:param name="orig_string"/>		
		<!--ding|dong|king|kong|blah}|ask="asdf"}|-->
		<!--|dong|king|kong|blah}|ask="asdf"}|-->
		<xsl:param name="divided_string_step1" select="concat(translate(translate($orig_string, ']', '}'), '.#[', '|||'), '|')"/>							
		<xsl:param name="divided_string">
			<xsl:choose>
				<xsl:when test="starts-with($divided_string_step1, '|')"><xsl:value-of select="substring($divided_string_step1, 2)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$divided_string_step1"/></xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<!--ding-->
		<!--dong-->
		<xsl:variable name="current_string">
			<xsl:choose>
				<xsl:when test="starts-with($divided_string, '|')"><xsl:value-of select="substring(substring-before($divided_string, '|'), 2)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="substring-before($divided_string, '|')"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--<xsl:value-of select="concat('{{current_string : ', $current_string, '}}')"/>-->
		<!--dong|king|kong|blah}|ask="asdf"}|-->
		<!--king|kong|blah}|ask="asdf"}|-->
		<!--<xsl:variable name="rest_of_string" select="substring-after($divided_string, '|')"/>		-->
		<!--
		<xsl:value-of select="concat('{{xpath : ', $xpath, '}}')"/>
		<xsl:value-of select="concat('{{orig_string : ', $orig_string, '}}')"/>
		<xsl:value-of select="concat('{{divided_string_step1 : ', $divided_string_step1, '}}')"/>
		<xsl:value-of select="concat('{{divided_string : ', $divided_string, '}}')"/>
		<xsl:value-of select="concat('{{current_string : ', $current_string, '}}')"/>
		<xsl:value-of select="concat('{{rest_of_string : ', $rest_of_string, '}}')"/>-->		
		
		<xsl:choose>
			<xsl:when test="$divided_string">
				<!--calculate position of next char reprsenting the selector type .#[-->
				<xsl:variable name="current_type_char_position" select="string-length($orig_string) - string-length($divided_string) + 1"/>				
				<!--<xsl:value-of select="concat('{{current_type_char_position : ', $current_type_char_position, '}}')"/>-->
				<!--generate xpath for current string-->
				<xsl:variable name="current_string_xpath">
					<xsl:choose>
						<xsl:when test="$current_type_char_position &gt; 0">
							<xsl:variable name="current_type_char" select="substring($orig_string, $current_type_char_position, 1)"/>
							<!--<xsl:value-of select="concat('{{current_type_char : ', $current_type_char, '}}')"/>-->
							<xsl:call-template name="single_css_selector_to_xpath">						
								<xsl:with-param name="string" select="$current_string"/>
								<xsl:with-param name="type" select="$current_type_char"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$current_string"/>
						</xsl:otherwise>
					</xsl:choose>					
				</xsl:variable>
				<!--keep building xpath-->
				<xsl:call-template name="css_selector_to_xpath">					
					<xsl:with-param name="xpath" select="concat($xpath, $current_string_xpath)"/>
					<xsl:with-param name="orig_string" select="$orig_string"/>
					<xsl:with-param name="divided_string" select="substring-after($divided_string, '|')"/>					
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="starts-with($xpath, '[')">*<xsl:value-of select="$xpath"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$xpath"/></xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="single_css_selector_to_xpath">
		<xsl:param name="type"/>	
		<xsl:param name="string"/>
		<xsl:choose>
			<!--class-->
			<xsl:when test="$type = '.'">[contains(concat(normalize-space(@class), ' '), '<xsl:value-of select="$string"/>')]</xsl:when>			
			<!--id-->
			<xsl:when test="$type = '#'">[@id='<xsl:value-of select="$string"/>']</xsl:when>
			<!--attribute-->
			<xsl:when test="$type = '['">[@<xsl:value-of select="translate($string, '}', '')"/>]</xsl:when>			
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@match | @select">
		<xsl:attribute name="{name()}">
			<xsl:call-template name="replace_css"/>
		</xsl:attribute>
	</xsl:template>	

	<xsl:template match="s:rule">		
		<!--mode_id used to handle nested rules-->
		<xsl:param name="mode_id"/> 
		<!--grab nested rules-->
		<xsl:variable name="rules" select="s:rule"/>		
		<xsl:variable name="new_mode_id">
			<xsl:if test="$rules">
				<xsl:value-of select="generate-id()"/>
			</xsl:if>
		</xsl:variable>	

		<!--create top level template-->
		<xsl:choose>
			<xsl:when test="not($mode_id)">
				<xsl:comment/>
				<xsl:comment>**************************************************************************************</xsl:comment>
				<xsl:comment>Top level template for s:rule</xsl:comment>
				<xsl:comment>   struc: <xsl:value-of select="@struc"/>
				</xsl:comment>				
				<xsl:comment>**************************************************************************************</xsl:comment>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment/>
				<xsl:comment>******************************************</xsl:comment>
				<xsl:comment>Nested s:rule</xsl:comment>
				<xsl:comment>   struc: <xsl:value-of select="@struc"/>
				</xsl:comment>
				<xsl:comment>   mode: <xsl:value-of select="$mode_id"/>
				</xsl:comment>							
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
			<xsl:variable name="struc_name" select="@struc"/>
			<xsl:variable name="anon_struc" select="s:struc"/>			
			<xsl:for-each select="$uses">								
				<xsl:for-each select="document(@href)">					
					<xsl:apply-templates select="key('struc_by_name', $struc_name)" mode="copy_struc">				
						<xsl:with-param name="mode_id" select="string($new_mode_id)"/>
					</xsl:apply-templates>
				</xsl:for-each>
			</xsl:for-each>
			<xsl:for-each select="$master_doc">				
				<xsl:apply-templates select="key('struc_by_name', $struc_name) | $anon_struc" mode="copy_struc">				
					<xsl:with-param name="mode_id" select="string($new_mode_id)"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</axsl:template>

		<!--create default xsl template for children if there are nested match rules-->
		<xsl:if test="$rules">
			<xsl:comment/>
			<xsl:comment>**************************************************</xsl:comment>
			<xsl:comment>Auto generated default nested rule</xsl:comment>	
			<xsl:comment>   mode: <xsl:value-of select="$new_mode_id"/>
			</xsl:comment>	
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
		<xsl:comment/>
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

	<!--s:struc(inner struc)-->
	<xsl:template match="s:inline-struc[@name]">		
		<xsl:param name="mode_id"/>		
		<xsl:variable name="select">
			<xsl:choose>
				<xsl:when test="@select">
					<xsl:value-of select="@select"/>
				</xsl:when>
				<xsl:otherwise>*</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:comment/>
		<xsl:comment>s:inline-struc[@name]</xsl:comment>		
		<axsl:for-each select="{$select}">
			<xsl:apply-templates select="node()">			
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="key('struc_by_name', @name)" mode="copy_struc">				
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:for-each>		
	</xsl:template>	

	<!--
		aliases
	-->	

	<!--s:inline-struc == xsl:for-each-->
	<xsl:template match="s:inline-struc">	
		<xsl:param name="mode_id"/>		
		<xsl:comment/>
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

	<!--s:attr == xsl:attribute-->
	<xsl:template match="s:attr">
		<xsl:param name="mode_id"/>			
		<xsl:comment>s:attr</xsl:comment>		
		<axsl:attribute>
			<xsl:apply-templates select="@* | node()">			
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:attribute>
	</xsl:template>

	<!--UTILITY TEMPLATES-->
	<xsl:template name="string-replace-all">
		<xsl:param name="text"/>
		<xsl:param name="replace"/>
		<xsl:param name="by"/>
		<xsl:choose>
			<xsl:when test="contains($text,$replace)">
				<xsl:value-of select="substring-before($text,$replace)"/>
				<xsl:value-of select="$by"/>
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="substring-after($text,$replace)"/>
					<xsl:with-param name="replace" select="$replace"/>
					<xsl:with-param name="by" select="$by"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>