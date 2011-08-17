<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:s="structure-stylesheet"	
	xmlns:axsl="axsl"	
	exclude-result-prefixes="s"	
>
	<xsl:output indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>

	<xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
	
	<xsl:param name="comments_on">yes</xsl:param>
	<xsl:key name="struc_by_name" match="s:struc" use="@name"/>
	<xsl:variable name="moves" select="//s:move"/>
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
	
	<xsl:template match="comment()">
		<xsl:if test="$comments_on">
			<xsl:copy-of select="."/>
		</xsl:if>
	</xsl:template>

	<!--create stylesheet-->
	<xsl:template match="s:stylesheet | s:transform">
		<axsl:stylesheet version="1.0" exclude-result-prefixes="s">
			<xsl:copy-of select="namespace::*|@*"/>					
			<!--**NOTE: using xml because it produces easier to read output. Should use method="html".-->
			<axsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
			<!--<axsl:output
				method="html"
				doctype-system="about:legacy-compat"
				indent="yes" 
			/>-->
			<axsl:strip-space elements="*"/>
			<axsl:key name="elem_by_id" match="@id/.." use="@id"/>
			
			<!--Remove moved elements-->
			<xsl:for-each select="$moves">
				<axsl:template match="*[@id = '{@id}']" priority="1"/>
			</xsl:for-each>
			<!--Create code for altering document structure.-->
			<axsl:template match="@*|node()">
				<axsl:copy>			
					<axsl:apply-templates select="@*|node()"/>
				</axsl:copy>		
			</axsl:template>

			<!--Don't collapse empty tags...-->
			<axsl:template match="*[not(node())]" priority="0">		
				<axsl:copy>
					<axsl:apply-templates select="@*"/>				
					<axsl:comment>empty</axsl:comment>
				</axsl:copy>
			</axsl:template>

			<!--...unless they are supposed to be collapsed.-->
			<axsl:template match="
				area[not(node())]|base[not(node())]|basefont[not(node())]|br[not(node())]|
				col[not(node())]|frame[not(node())]|hr[not(node())]|img[not(node())]|
				input[not(node())]|isindex[not(node())]|link[not(node())]|meta[not(node())]|
				param[not(node())]|nextid[not(node())]|bgsound[not(node())]|embed[not(node())]|
				keygen[not(node())]|spacer|wbr[not(node())]"
				priority="0"
			>
				<axsl:copy-of select="."/>			
			</axsl:template>

			<xsl:apply-templates select="@* | node()"/>		

			<axsl:template match="processing-instruction('xml-stylesheet')"/>	
			
			<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
			<xsl:if test="$comments_on"><xsl:comment>**************************************************************************************</xsl:comment></xsl:if>
			<xsl:if test="$comments_on"><xsl:comment>* HELPER TEMPLATES</xsl:comment></xsl:if>
			<xsl:if test="$comments_on"><xsl:comment>**************************************************************************************</xsl:comment></xsl:if>
			
			<!--Replace String-->
			<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
			<xsl:if test="$comments_on"><xsl:comment>Helper Template: replace_string</xsl:comment></xsl:if>
			<axsl:template name="replace_string">
				<axsl:param name="string"/>
				<axsl:param name="replace"/>
				<axsl:param name="with"/>
				
				<!--<axsl:message> $string (<axsl:value-of select="$string"/>)</axsl:message>
				<axsl:message> $replace (<axsl:value-of select="$replace"/>)</axsl:message>
				<axsl:message> $with (<axsl:value-of select="$with"/>)</axsl:message>-->
				
				<axsl:choose>
					<axsl:when test="contains($string, $replace)">
						<axsl:value-of select="substring-before($string, $replace)"/>
						<axsl:value-of select="$with"/>
						<axsl:call-template name="replace_string">
							<axsl:with-param name="string" select="substring-after($string, $replace)"/>
							<axsl:with-param name="replace" select="$replace"/>
							<axsl:with-param name="with" select="$with"/>
						</axsl:call-template>
					</axsl:when>
					<axsl:otherwise>
						<!--<axsl:message> $string done (<axsl:value-of select="$string"/>)</axsl:message>-->
						<axsl:value-of select="$string"/>
					</axsl:otherwise>
				</axsl:choose>
			</axsl:template>
			
			<!--Remove Classes-->
			<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
			<xsl:if test="$comments_on"><xsl:comment>Helper Template: remove_classes</xsl:comment></xsl:if>
			<axsl:template name="remove_classes">
				<!--class_attr spacing should be normalized with a space added to start and end-->
				<axsl:param name="class_attr" select="''"/>
				<!--class_attr spacing should be normalized with a space added to start and end-->
				<axsl:param name="classes" select="''"/>
				<!--<axsl:message> REMOVE class_attr (<axsl:value-of select="$class_attr"/>)</axsl:message>
				<axsl:message> REMOVE classes (<axsl:value-of select="$classes"/>)</axsl:message>-->
				<axsl:choose>
					<axsl:when test="normalize-space($classes)">
						<!--current class (put spaces on either side)-->
						<axsl:variable name="current_class" select="concat(' ', substring-before(substring-after($classes, ' '), ' '), ' ')"/>
						<!--<axsl:message> $current_class (<axsl:value-of select="$current_class"/>)</axsl:message>-->
						
						<axsl:variable name="updated_class_attr">					
							<axsl:call-template name="replace_string">
								<axsl:with-param name="string" select="$class_attr"/>
								<axsl:with-param name="replace" select="$current_class"/>
								<axsl:with-param name="with" select="' '"/>
							</axsl:call-template>								
						</axsl:variable>
						
						<!--<axsl:message> $updated_class_attr (<axsl:value-of select="$updated_class_attr"/>)</axsl:message>-->

						<axsl:call-template name="remove_classes">					
							<axsl:with-param name="class_attr" select="$updated_class_attr"/>
							<axsl:with-param name="classes" select="concat(' ', substring-after($classes, $current_class))"/>				
						</axsl:call-template>

					</axsl:when>
					<axsl:otherwise>
						<axsl:value-of select="normalize-space($class_attr)"/>
						<!--<axsl:message> * REMOVE classes complete (<axsl:value-of select="normalize-space($class_attr)"/>)</axsl:message>-->
					</axsl:otherwise>
				</axsl:choose>

			</axsl:template>

			<!--Add Classes-->
			<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
			<xsl:if test="$comments_on"><xsl:comment>Helper Template: add_classes</xsl:comment></xsl:if>
			<axsl:template name="add_classes">
				<!--class_attr spacing should be normalized with a space added to start and end-->
				<axsl:param name="class_attr" select="''"/>
				<!--class_attr spacing should be normalized with a space added to start and end-->
				<axsl:param name="classes" select="''"/>		
				<!--<axsl:message> ADD class_attr (<axsl:value-of select="$class_attr"/>)</axsl:message>
				<axsl:message> ADD classes (<axsl:value-of select="$classes"/>)</axsl:message>-->
				<axsl:choose>
					<axsl:when test="normalize-space($classes)">
						<!--current class (put spaces on either side)-->
						<axsl:variable name="current_class" select="concat(' ', substring-before(substring-after($classes, ' '), ' '), ' ')"/>			
						<!--<axsl:message> $current_class (<axsl:value-of select="$current_class"/>)</axsl:message>-->
						
						<axsl:variable name="updated_class_attr">
							<axsl:choose>
								<axsl:when test="not(contains($class_attr, $current_class))">
									<axsl:value-of select="concat($class_attr, substring-after($current_class, ' '))"/>
								</axsl:when>
								<axsl:otherwise>
									<axsl:value-of select="$class_attr"/>
								</axsl:otherwise>
							</axsl:choose>					
						</axsl:variable>
						
						<!--<axsl:message> $updated_class_attr (<axsl:value-of select="$updated_class_attr"/>)</axsl:message>-->

						<axsl:call-template name="add_classes">					
							<axsl:with-param name="class_attr" select="$updated_class_attr"/>
							<axsl:with-param name="classes" select="concat(' ', substring-after($classes, $current_class))"/>				
						</axsl:call-template>

					</axsl:when>
					<axsl:otherwise>
						<axsl:value-of select="normalize-space($class_attr)"/>
						<!--<axsl:message> * ADD classes complete (<axsl:value-of select="normalize-space($class_attr)"/>)</axsl:message>-->
					</axsl:otherwise>
				</axsl:choose>

			</axsl:template>
			
			<!--Calculate Class-->
			<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
			<xsl:if test="$comments_on"><xsl:comment>Helper Template: calculate_class</xsl:comment></xsl:if>
			<axsl:template name="calculate_class">
				<axsl:param name="class" select="''"/>
				<axsl:param name="classes_to_remove" select="''"/>
				<axsl:param name="classes_to_add"  select="''"/>
				
				<axsl:variable name="classes_removed">		
					<!--<axsl:message>=========xxxxxxxxxxxxxxxxxx========= remvoe class_attr (<axsl:value-of select="concat(' ', normalize-space(@class), ' ')"/>)</axsl:message>-->
					<axsl:call-template name="remove_classes">
						<axsl:with-param name="class_attr" select="$class"/>
						<axsl:with-param name="classes" select="$classes_to_remove"/>
					</axsl:call-template>			
				</axsl:variable>
				<!--<axsl:message>$classes_removed (<axsl:value-of select="$classes_removed"/>)</axsl:message>-->
				
				<axsl:variable name="classes_added">
					<axsl:call-template name="add_classes">
						<axsl:with-param name="class_attr" select="concat(' ', normalize-space($classes_removed), ' ')"/>
						<axsl:with-param name="classes" select="$classes_to_add"/>
					</axsl:call-template>
				</axsl:variable>	
				<!--<axsl:message>$classes_added (<axsl:value-of select="$classes_added"/>)</axsl:message>-->	

				<axsl:value-of select="$classes_added"/>
			</axsl:template>
			
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
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment>[START] s:use <xsl:value-of select="@href"/>
		</xsl:comment></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
		<xsl:apply-templates select="document(@href)/*/*"/>
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment>[END] s:use <xsl:value-of select="@href"/>
		</xsl:comment></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
	</xsl:template>

	<!--replace s:this with xsl:copy or given tag-name-->
	<xsl:template match="s:this">
		<xsl:param name="mode_id"/>
		<xsl:variable name="tag" select="@s:tag-name"/>		
		<xsl:variable name="inner">
			<!--gather removed attributes-->
			<xsl:variable name="removed_attr" select="concat(' ', normalize-space(@s:remove-attr), ' ')"/>
			
			<!--only add attributes if not removed-->
			<xsl:choose>
				<xsl:when test="normalize-space($removed_attr) = ''">
					<axsl:apply-templates select="@*"/>
				</xsl:when>
				<xsl:otherwise>
					<axsl:apply-templates select="@*[not(contains('{$removed_attr}', concat(' ', name(), ' ')))]"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="@s:add-class or @s:remove-class and not(contains($removed_attr, 'class'))">		
				<!--<axsl:message> removed (<axsl:value-of select="$classes_removed"/>)</axsl:message>
				<axsl:message> added (<axsl:value-of select="$classes_added"/>)</axsl:message>-->
				<axsl:attribute name="class">
					<axsl:call-template name="calculate_class">
						<axsl:with-param name="class" select="concat(' ', normalize-space(@class), ' ')"/>
						<xsl:if test="@s:remove-class">
							<axsl:with-param name="classes_to_remove" select="'{concat(' ', normalize-space(@s:remove-class), ' ')}'"/>
						</xsl:if>
						<xsl:if test="@s:add-class">
							<axsl:with-param name="classes_to_add" select="'{concat(' ', normalize-space(@s:add-class), ' ')}'"/>
						</xsl:if>
					</axsl:call-template>
				</axsl:attribute>			
			</xsl:if>			
			
			<!--keep going...-->
			<xsl:apply-templates select="@* | node()">
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment>s:this</xsl:comment></xsl:if>

		<xsl:choose>
			<xsl:when test="$tag">				
				<xsl:element name="{$tag}">
					<xsl:copy-of select="$inner"/>
				</xsl:element>			
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
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment>s:this attribute</xsl:comment></xsl:if>
		<axsl:attribute name="{name()}">
			<xsl:value-of select="."/>
		</axsl:attribute>
	</xsl:template>

	<!--Remove these tags and attributes-->
	<xsl:template match="@s:tag-name | @s:remove-attr | @s:remove-class | @s:add-class | s:stylesheet/s:struc | s:stylesheet/s:struc | @struc" priority="1"/>		

	<!--Replace css function in match and select attributes with valid xpath expression-->
	<xsl:template name="replace_css">
		<xsl:param name="match_attr" select="normalize-space(.)"/>				
		<xsl:choose>					
			<xsl:when test="contains($match_attr, 'css(')">
				<xsl:variable name="css" select="substring-before(substring-after($match_attr, 'css('), ')')"/>								
				<xsl:variable name="before_css" select="substring-before($match_attr, 'css(')"/>		
				<xsl:variable name="after_css" select="substring-after($match_attr, concat('css(', $css, ')'))"/>		

				<xsl:variable name="css_selector">
					<xsl:call-template name="css_selector_to_xpath">
						<xsl:with-param name="orig_string" select="$css"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:call-template name="replace_css">
					<xsl:with-param name="match_attr" select="concat($before_css, $css_selector, $after_css)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>				
				<xsl:value-of select="$match_attr"/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>	

	<xsl:template name="css_selector_to_xpath">
		<!--build up xpath-->
		<xsl:param name="xpath" select="''"/>
		<!--ding.dong.king#kong[blah][ask='asdf']-->		
		<xsl:param name="orig_string"/>		
		<!--ding|dong|king|kong|blah}|ask="asdf"}|-->		
		<xsl:param name="divided_string_step1" select="concat(translate(translate($orig_string, ']', '}'), '.#[', '|||'), '|')"/>							
		<xsl:param name="divided_string">
			<xsl:choose>
				<xsl:when test="starts-with($divided_string_step1, '|')">
					<xsl:value-of select="substring($divided_string_step1, 2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$divided_string_step1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<!--ding-->		
		<xsl:variable name="current_string">
			<xsl:choose>
				<xsl:when test="starts-with($divided_string, '|')">
					<xsl:value-of select="substring(substring-before($divided_string, '|'), 2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-before($divided_string, '|')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$divided_string">
				<!--calculate position of next char reprsenting the selector type .#[-->
				<xsl:variable name="current_type_char_position" select="string-length($orig_string) - string-length($divided_string) + 1"/>						
				<!--generate xpath for current string-->
				<xsl:variable name="current_string_xpath">
					<xsl:choose>
						<xsl:when test="$current_type_char_position &gt; 0">
							<xsl:variable name="current_type_char" select="substring($orig_string, $current_type_char_position, 1)"/>							
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
					<xsl:when test="starts-with($xpath, '[')">*<xsl:value-of select="$xpath"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$xpath"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="single_css_selector_to_xpath">
		<xsl:param name="type"/>	
		<xsl:param name="string"/>
		<xsl:choose>
			<!--class-->
			<xsl:when test="$type = '.'">[contains(concat(' ', normalize-space(@class), ' '), ' <xsl:value-of select="$string"/> ')]</xsl:when>			
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
				<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
				<xsl:if test="$comments_on"><xsl:comment>**************************************************************************************</xsl:comment></xsl:if>
				<xsl:if test="$comments_on"><xsl:comment>Top level template for s:rule</xsl:comment></xsl:if>
				<xsl:if test="$comments_on"><xsl:comment>   struc: <xsl:value-of select="@struc"/>
				</xsl:comment></xsl:if> 				
				<xsl:if test="$comments_on"><xsl:comment>**************************************************************************************</xsl:comment></xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
				<xsl:if test="$comments_on"><xsl:comment>******************************************</xsl:comment></xsl:if>
				<xsl:if test="$comments_on"><xsl:comment>Nested s:rule</xsl:comment></xsl:if>
				<xsl:if test="$comments_on"><xsl:comment>   struc: <xsl:value-of select="@struc"/>
				</xsl:comment></xsl:if>
				<xsl:if test="$comments_on"><xsl:comment>   mode: <xsl:value-of select="$mode_id"/>
				</xsl:comment></xsl:if>							
				<xsl:if test="$comments_on"><xsl:comment>******************************************</xsl:comment></xsl:if>
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
			<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
			<xsl:if test="$comments_on"><xsl:comment>**************************************************</xsl:comment></xsl:if>
			<xsl:if test="$comments_on"><xsl:comment>Auto generated default nested rule</xsl:comment>	</xsl:if>
			<xsl:if test="$comments_on"><xsl:comment>   mode: <xsl:value-of select="$new_mode_id"/>
			</xsl:comment></xsl:if>	
			<xsl:if test="$comments_on"><xsl:comment>**************************************************</xsl:comment></xsl:if>
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
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment>s:apply-rules</xsl:comment></xsl:if>
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
	
	<!--s:move[@struc]-->
	<xsl:template match="s:move[@id][@struc]">
		<xsl:param name="mode_id"/>		
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment>s:move[@struc]</xsl:comment></xsl:if>
		<axsl:message>hmmmm (@id = <axsl:value-of select="'{@id}'"/>, <axsl:value-of select="count(key('elem_by_id', '{@id}')) "/></axsl:message>
		<axsl:for-each select="key('elem_by_id', '{@id}')">
			<xsl:apply-templates select="key('struc_by_name', @struc)" mode="copy_struc">				
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:for-each>		
	</xsl:template>
	
	<!--s:move-->
	<xsl:template match="s:move[@id]">
		<xsl:param name="mode_id"/>		
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment>s:move</xsl:comment></xsl:if>
		<xsl:choose>
			<!--We've got an inline structure.-->
			<xsl:when test="*">
				<axsl:for-each select="key('elem_by_id', '{@id}')">
					<xsl:apply-templates select="node()">			
						<xsl:with-param name="mode_id" select="$mode_id"/>
					</xsl:apply-templates>
				</axsl:for-each>
			</xsl:when>
			<!--No inline structure. Just do a copy.-->
			<xsl:otherwise>
				<axsl:for-each select="key('elem_by_id', '{@id}')">
					<axsl:copy>
						<axsl:apply-templates select="@*|node()">
							<xsl:if test="$mode_id">
								<xsl:attribute name="mode"><xsl:value-of select="$mode_id"/></xsl:attribute>
							</xsl:if>
						</axsl:apply-templates>
					</axsl:copy>
				</axsl:for-each>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<!--s:inline-struc[@struc]-->
	<xsl:template match="s:inline-struc[@struc]">		
		<xsl:param name="mode_id"/>		
		<xsl:variable name="select">
			<xsl:choose>
				<xsl:when test="@select">
					<xsl:value-of select="@select"/>
				</xsl:when>
				<xsl:otherwise>*</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment>s:inline-struc[@struc]</xsl:comment>		</xsl:if>
		<axsl:for-each select="{$select}">
			<xsl:apply-templates select="node()">			
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="key('struc_by_name', @struc)" mode="copy_struc">				
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:for-each>		
	</xsl:template>	

	<!--s:inline-struc-->
	<xsl:template match="s:inline-struc">	
		<xsl:param name="mode_id"/>	
		<xsl:variable name="select">
			<xsl:choose>
				<xsl:when test="@select">
					<xsl:value-of select="@select"/>
				</xsl:when>
				<xsl:otherwise>*</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$comments_on"><xsl:comment/></xsl:if>
		<xsl:if test="$comments_on"><xsl:comment>s:inline-struc</xsl:comment></xsl:if>
		<xsl:choose>
			<!--We've got an inline structure.-->
			<xsl:when test="*">
				<axsl:for-each select="{$select}">
					<xsl:apply-templates select="node()">		
						<xsl:with-param name="mode_id" select="$mode_id"/>
					</xsl:apply-templates>
				</axsl:for-each>
			</xsl:when>
			<!--No inline structure. Just do a copy.-->
			<xsl:otherwise>
				<axsl:for-each select="{$select}">
					<axsl:copy>
						<axsl:apply-templates select="@*|node()">
							<xsl:if test="$mode_id">
								<xsl:attribute name="mode"><xsl:value-of select="$mode_id"/></xsl:attribute>
							</xsl:if>
						</axsl:apply-templates>
					</axsl:copy>
				</axsl:for-each>
			</xsl:otherwise>
		</xsl:choose>		
		
	</xsl:template>	
	
	<!--
		aliases
	-->	

	<!--s:var == xsl:variable-->
	<xsl:template match="s:var">
		<xsl:param name="mode_id"/>		
		<xsl:if test="$comments_on"><xsl:comment>s:var</xsl:comment></xsl:if>
		<axsl:variable>
			<xsl:apply-templates select="@* | node()">			
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:variable>
	</xsl:template>

	<!--s:val == xsl:value-of-->
	<xsl:template match="s:val">
		<xsl:param name="mode_id"/>			
		<xsl:if test="$comments_on"><xsl:comment>s:val</xsl:comment>		</xsl:if>
		<axsl:value-of>
			<xsl:apply-templates select="@* | node()">			
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:value-of>
	</xsl:template>

	<!--s:attr == xsl:attribute (get rid of this?)-->
	<xsl:template match="s:attr">
		<xsl:param name="mode_id"/>			
		<xsl:if test="$comments_on"><xsl:comment>s:attr</xsl:comment>		</xsl:if>
		<axsl:attribute>
			<xsl:apply-templates select="@* | node()">			
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</axsl:attribute>
	</xsl:template>

</xsl:stylesheet>