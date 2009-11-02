<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:s="structure_stylesheet"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:axsl="axsl"
>  
	<xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
	<xsl:key name="struc_by_name" match="s:structure_stylesheet/s:struc" use="@name"/>

	<!--
		Identity transform (what comes in goes out)
	-->		
	<xsl:template match="@*|node()">
		<xsl:param name="apply_attr"/>
		<xsl:param name="mode_id"/>
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()">
				<xsl:with-param name="apply_attr" select="$apply_attr"/>
				<xsl:with-param name="mode_id" select="$mode_id"/>
			</xsl:apply-templates>
		</xsl:copy>		
	</xsl:template>	

	<xsl:template match="s:structure_stylesheet">
		<axsl:stylesheet 
			version="1.0" 	
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xmlns="http://www.w3.org/1999/xhtml"
			exclude-result-prefixes="s"
		>  
			<axsl:template match="@*|node()">
				<axsl:copy>			
					<axsl:apply-templates select="@*|node()"/>
				</axsl:copy>		
			</axsl:template>

			<xsl:apply-templates select="s:rule/s:match"/>		

			<!--template for adding classes-->			
			<axsl:template name="add_classes">
				<axsl:param name="orig_classes"/>		
				<axsl:param name="new_classes"/>
				<axsl:param name="current_new_class"/>
				<axsl:param name="class_string"/>		
				
				<axsl:choose>
					<axsl:when test="$new_classes">
						<axsl:variable name="next_new_classes" select="substring-after($new_classes, $current_new_class)"/>		
						<axsl:variable name="next_current_new_class" select="concat(substring-before($next_new_classes, ' '), ' ')"/>					
						<axsl:variable name="next_class_string">
							<axsl:choose>
								<axsl:when test="not(contains($orig_classes, $current_new_class))">
									<axsl:value-of select="concat($current_new_class, $class_string)"/>
								</axsl:when>
								<axsl:otherwise>
									<axsl:value-of select="$class_string"/>
								</axsl:otherwise>
							</axsl:choose>			
						</axsl:variable>	

						<axsl:call-template name="add_classes">
							<axsl:with-param name="orig_classes" select="$orig_classes"/>
							<axsl:with-param name="new_classes" select="$next_new_classes"/>
							<axsl:with-param name="current_new_class" select="$next_current_new_class"/>
							<axsl:with-param name="class_string" select="$next_class_string"/>
						</axsl:call-template>
					</axsl:when>
					<axsl:otherwise>
						<axsl:value-of select="normalize-space($class_string)"/>
					</axsl:otherwise>
				</axsl:choose>
			</axsl:template>
		</axsl:stylesheet>
	</xsl:template>

	<xsl:template match="s:match">		
		<!--mode_id used to handle nested rules-->
		<xsl:param name="mode_id"/> 
		<xsl:variable name="new_mode_id" select="generate-id()"/>		

		<!--grab  attributes of apply tag-->
		<xsl:variable name="apply_attr" select="../s:apply/@*"/>

		<!--grab selectors-->
		<xsl:variable name="tag_sel" select="s:tag"/>
		<xsl:variable name="attr_sel" select="s:attr"/>
		<xsl:variable name="class_sel" select="s:class"/>		
		<xsl:variable name="id_sel" select="s:id"/>

		<!--grab nested rules-->
		<xsl:variable name="rules" select="../s:rule"/>

		<!--calculate priority for match rule-->		
		<xsl:variable name="selector_priority" select="100*count($id_sel) + 10*count($attr_sel|$class_sel) + count($tag_sel)"/>

		<!--generate tag pattern-->
		<xsl:variable name="tag">
			<xsl:choose>
				<xsl:when test="s:tag">
					<xsl:value-of select="$tag_sel"/>
				</xsl:when>
				<xsl:otherwise>*</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--generate id pattern-->
		<xsl:variable name="id">			
			<xsl:if test="s:id">[@id = '<xsl:value-of select="$id_sel"/>']</xsl:if>			
		</xsl:variable>

		<!--generate class patterns-->
		<xsl:variable name="classes">
			<xsl:apply-templates select="$class_sel" mode="generate_class_pattern"/>
		</xsl:variable>

		<!--generate attribute patterns-->
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
		<axsl:template match="h:{$tag}{$id}{$classes}{$attrs}" priority="{$selector_priority}">
			<xsl:if test="$mode_id">
				<xsl:attribute name="mode">
					<xsl:value-of select="$mode_id"/>
				</xsl:attribute>
			</xsl:if>

			<xsl:variable name="maybe_mode_id">
				<xsl:if test="$rules">
					<xsl:value-of select="$new_mode_id"/>
				</xsl:if>
			</xsl:variable>

			<xsl:apply-templates select="key('struc_by_name', ../s:apply/@s:struc)">
				<xsl:with-param name="apply_attr" select="$apply_attr"/>
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
		<xsl:variable name="class_and_space" select="concat(., ' ')"/>		
		<xsl:text>[contains(concat(normalize-space(@class), ' '), '</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text> ')]</xsl:text>
	</xsl:template>

	<!--generate attr patterns-->
	<xsl:template match="s:attr" mode="generate_attr_pattern">						
		<xsl:value-of select="concat('[@', @name, ']')"/>				
	</xsl:template>

	<xsl:template match="s:attr[string(.)]" mode="generate_attr_pattern">		
		<xsl:text>[@</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text> = '</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>']</xsl:text>
	</xsl:template>

	<!--struc-->
	<xsl:template match="s:struc">		
		<xsl:param name="apply_attr"/>
		<xsl:param name="mode_id"/>
		<xsl:apply-templates select="node()">
			<xsl:with-param name="apply_attr" select="$apply_attr"/>
			<xsl:with-param name="mode_id" select="$mode_id"/>
		</xsl:apply-templates>
	</xsl:template>

	<!--elem-->
	<xsl:template match="s:elem">
		<xsl:param name="apply_attr"/>
		<xsl:param name="mode_id"/>		

		<xsl:variable name="elem_tag_name" select="@s:tag_name"/>
		<xsl:variable name="apply_tag_name" select="$apply_attr[name() = 's:tag_name']"/>		

		<xsl:variable name="elem_add_classes" select="concat(normalize-space(@s:add_classes), ' ')"/>
		<xsl:variable name="apply_add_classes" select="concat(normalize-space($apply_attr[name() = 's:add_classes']), ' ')"/>		

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
			<xsl:apply-templates select="@*"/>			

			<!--generate attributes for apply tag (overrides attributes for current node and elem tag)-->
			<xsl:apply-templates select="$apply_attr"/>	

			<!--gather classes to add-->
			<xsl:variable name="classes_to_add">
				<xsl:call-template name="add_classes">
					<xsl:with-param name="orig_classes" select="$elem_add_classes"/>
					<xsl:with-param name="new_classes" select="$apply_add_classes"/>
					<xsl:with-param name="current_new_class" select="concat(substring-before($apply_add_classes, ' '), ' ')"/>
					<xsl:with-param name="class_string" select="$elem_add_classes"/>
				</xsl:call-template>
			</xsl:variable>						

			<!--don't generate code to add classes unlesss there are classes to add-->
			<xsl:if test="normalize-space($classes_to_add)">
				<axsl:choose>				
					<axsl:when test="@class">
						<axsl:variable name="orig_classes" select="concat(normalize-space(@class), ' ')"/>
						<axsl:attribute name="class">
							<axsl:call-template name="add_classes">
								<axsl:with-param name="orig_classes" select="$orig_classes"/>
								<axsl:with-param name="new_classes" select="'{$classes_to_add} '"/>
								<axsl:with-param name="current_new_class" select="'{concat(substring-before($classes_to_add, ' '), ' ')}'"/>
								<axsl:with-param name="class_string" select="$orig_classes"/>
							</axsl:call-template>
						</axsl:attribute>
					</axsl:when>
					<axsl:otherwise>
						<axsl:attribute name="class">
							<xsl:value-of select="$classes_to_add"/>
						</axsl:attribute>
					</axsl:otherwise>
				</axsl:choose>
			</xsl:if>

			<!--reproduce contents of elem tag-->
			<xsl:apply-templates select="node()">
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
	<xsl:template match="s:elem/@*|s:apply/@*">	
		<axsl:attribute name="{name()}">
			<xsl:value-of select="."/>
		</axsl:attribute>
	</xsl:template>

	<!--don't reproduce s: attrubutes-->
	<xsl:template match="s:elem/@s:*|s:apply/@s:*"/>

	<!--recursive template for adding classes-->
	<xsl:template name="add_classes">
		<xsl:param name="orig_classes"/>		
		<xsl:param name="new_classes"/>
		<xsl:param name="current_new_class"/>
		<xsl:param name="class_string"/>		
		
		<xsl:choose>
			<xsl:when test="$new_classes">
				<xsl:variable name="next_new_classes" select="substring-after($new_classes, $current_new_class)"/>		
				<xsl:variable name="next_current_new_class" select="concat(substring-before($next_new_classes, ' '), ' ')"/>					
				<xsl:variable name="next_class_string">
					<xsl:choose>
						<xsl:when test="not(contains($orig_classes, $current_new_class))">
							<xsl:value-of select="concat($current_new_class, $class_string)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$class_string"/>
						</xsl:otherwise>
					</xsl:choose>			
				</xsl:variable>	

				<xsl:call-template name="add_classes">
					<xsl:with-param name="orig_classes" select="$orig_classes"/>
					<xsl:with-param name="new_classes" select="$next_new_classes"/>
					<xsl:with-param name="current_new_class" select="$next_current_new_class"/>
					<xsl:with-param name="class_string" select="$next_class_string"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($class_string)"/>
			</xsl:otherwise>
		</xsl:choose>
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