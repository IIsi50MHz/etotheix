<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:s="structure_stylesheet"
	xmlns:h="http://www.w3.org/1999/xhtml"
>  
	<xsl:output method="html" indent="yes"/>

	<!--grab all structure stylesheets-->
	<!--<xsl:variable name="structure_stylesheet_filename" select="/*/*/s:use_structure_stylesheet"/>-->
	<xsl:variable name="structure_stylesheet_filename" select="/h:html/h:head/h:link[@type='xml/sss']/@href"/>
	<xsl:variable name="structure_stylesheet" select="document($structure_stylesheet_filename)/*"/>
	<!--grab all structure stylesheet rules-->
	<xsl:variable name="rules" select="$structure_stylesheet/s:rule/s:sel"/>
	<xsl:variable name="last_rule_id" select="generate-id($rules[last()])"/>
	<xsl:variable name="count_rules" select="count($rules)"/>
	<!--key for grabbing all structure_rules that have a given id (key('id', 'anIdName')/..)-->
	<xsl:key name="rule_id" match="s:id" use="."/>
	<!--key for grabbing all structure_rules that have a given class (key('class', 'aClassName')/..)-->
	<xsl:key name="rule_class" match="s:class" use="."/>
		
	<!--
		Identity transform (what comes in goes out)
	-->
	
	<xsl:template match="/*">
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>		
	</xsl:template>	
	
	<xsl:template match="@*|node()">
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>		
	</xsl:template>	
		
	<xsl:template match="s:use_structure_stylesheet" mode="structure_stylesheet"/>
	
	<!--
		Templates gathering structure stylesheet rules
		
		* have a variable that holds all rules from all stylesheets
		* for each element in the main doc (with class or id)
			* for each rule, check for match
				* if rule has an id, check if element has matching id
					* if no match, jump to next rule
					* if match, check rule class match
				* if rule has classes, check if element has the class
					* if element doesn't have the class jump to next rule
					* if match, check next class
				* if rule is a match, keep it and go on the next rule until we reach the last rule	
		* once all matching rules are gathered, figure out the once with the highest precedence
			* apply the rule to the element				
	-->
	
	<!--**TODO?: add match for tag name in addition to id and class-->	
	<!--for each element in the main doc (with class or id)-->	
	<xsl:template match="*[@id|@class]">
		<!--* for each rule, check for match-->	
		<xsl:call-template name="gather_matching_rules">
			<xsl:with-param name="id_string" select="normalize-space(@id)"/>
			<!--ensure every class name in class string has exactly one space after it (so we can pluck out the last class the same way as other classes)-->
			<xsl:with-param name="class_string" select="concat(normalize-space(@class), ' ')"/>
			<xsl:with-param name="tag_string" select="name()"/>
			<xsl:with-param name="current_node" select="."/>						
		</xsl:call-template>		
	</xsl:template>
	
	<!--* for each rule, check for match-->
	<xsl:template name="gather_matching_rules">
		<xsl:param name="id_string"/>
		<xsl:param name="class_string"/>
		<xsl:param name="tag_string"/>
		<xsl:param name="current_node"/>		
		<xsl:param name="gathered_rules" select="$rules[0][false]"/>
		<xsl:param name="current_rule" select="$rules[0]"/>
		<xsl:param name="current_rule_index" select="0"/> 

		<!--grab any id selector in current rule-->
		<xsl:variable name="rule_id" select="$current_rule/s:id"/>
		<!--pick out matching id selector-->
		<xsl:variable name="matching_rule_id" select="$rule_id[$rule_id = $id_string]"/>
		
		<!--grab all class selectors in current rule-->
		<xsl:variable name="rule_classes" select="$current_rule/s:class"/>
		<!--pick out matching class selectors-->
		<xsl:variable name="matching_rule_classes" select="$rule_classes[contains($class_string, concat(., ' '))]"/>
		
		<!--grab any id selector in current rule-->
		<xsl:variable name="rule_tag" select="$current_rule/s:tag"/>
		<!--pick out matching id selector-->
		<xsl:variable name="matching_rule_tag" select="$rule_tag[$rule_tag = $tag_string]"/>
		
		<!--if the current node matches the current rule, gather the rule-->
		<xsl:variable name="more_gathered_rules" select="$gathered_rules | $current_rule[
			count($rule_id) = count($matching_rule_id) and 
			count($rule_classes) = count($matching_rule_classes) and
			count($rule_tag) = count($matching_rule_tag)
		]"/>
<!--<h1 style="color:red"><xsl:value-of select="concat($tag_string, '[', $rule_tag, ']')"/></h1>-->
		<!--keep gathering rules until we reach the last one-->
<!--<h1 style="color:orange"><xsl:value-of select="concat($current_rule_index,  '[current_rule_id = ', $current_rule/s:id, ']', '[current_node = ', $current_node, ']', 'count more_gathered_rules = ', count($more_gathered_rules), '{count matching_rule_id = ', count($matching_rule_id),'}', $rule_id, $id_string)"/></h1>		-->				
		<xsl:choose>
			<xsl:when test="generate-id($current_rule) != $last_rule_id">
				<xsl:variable name="next_rule_index" select="$current_rule_index + 1"/>
				<xsl:call-template name="gather_matching_rules">
					<xsl:with-param name="class_string" select="$class_string"/>
					<xsl:with-param name="id_string" select="$id_string"/>
					<xsl:with-param name="tag_string" select="$tag_string"/>					
					<xsl:with-param name="current_node" select="$current_node"/>
					<xsl:with-param name="gathered_rules" select="$more_gathered_rules"/>
					<xsl:with-param name="current_rule" select="$rules[$next_rule_index]"/>
					<xsl:with-param name="current_rule_index" select="$next_rule_index"/>				
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!--once we've got all the matching rules, find most specific matching rule-->
<!--<h1 style="color:brown"><xsl:value-of select="concat($current_rule_index,  '[', $current_rule/s:id, ']', '[', $current_node, ']', 'NUM MATCHES = ', count($more_gathered_rules))"/></h1>-->		
				<xsl:call-template name="find_most_specific_rule">
					<xsl:with-param name="matching_rules" select="$more_gathered_rules"/>			
					<xsl:with-param name="current_node" select="$current_node"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>		
	
	<!--find most specific rule-->
	<xsl:template name="find_most_specific_rule">		
		<xsl:param name="matching_rules"/>		
		<xsl:param name="current_node"/>			
<!--<h1 style="color:red"><xsl:value-of select="concat(count(matching_rules), '[', $current_node, ']')"/></h1>-->
		
		<!--see if there's more than one rule--> 
		<xsl:choose>
			<xsl:when test="count($matching_rules) > 1">		
				<!--grab first two rules-->
				<xsl:variable name="first_rule" select="$matching_rules[position() = 1]"/>
				<xsl:variable name="second_rule" select="$matching_rules[position() = 2]"/>
	
				<!--see if first two rules have an id-->
				<xsl:variable name="first_rule_id_count" select="count($first_rule[s:id])"/>
				<xsl:variable name="second_rule_id_count" select="count($second_rule[s:id])"/>	

				<!--count classes-->
				<xsl:variable name="first_rule_class_count" select="count($first_rule[s:class])"/>
				<xsl:variable name="second_rule_class_count" select="count($second_rule[s:class])"/>	

				<!--see if first two rules have a tag-->
				<xsl:variable name="first_rule_tag_count" select="count($first_rule[s:tag])"/>
				<xsl:variable name="second_rule_tag_count" select="count($second_rule[s:tag])"/>	

				
				<!--figure out which of the first two rules has the highest precedence-->
				
				
				<xsl:choose>
					<!--get rid of the first rule if only second rule has id-->
					<xsl:when test="$first_rule_id_count &lt; $second_rule_id_count">
						<!--<h3 style="color:darkgreen">$first_rule_id_count &lt; $second_rule_id_count</h3>-->
						<xsl:call-template name="find_most_specific_rule">
							<xsl:with-param name="matching_rules" select="$matching_rules[position() >= 2]"/>
							<xsl:with-param name="current_node" select="$current_node"/>
						</xsl:call-template>
					</xsl:when>
					
					<!--if only first rule has id, throw out second rule-->
					<xsl:when test="$first_rule_id_count > $second_rule_id_count">
					<!--<h3 style="color:darkgreen">$first_rule_id_count > $second_rule_id_count</h3>-->
						<xsl:call-template name="find_most_specific_rule">
							<xsl:with-param name="matching_rules" select="$first_rule|$matching_rules[position() > 2]"/>
							<xsl:with-param name="current_node" select="$current_node"/>
						</xsl:call-template>
					</xsl:when>			
					
					<!--if id count didn't determine precedence, compare number of classes-->					
					<!--use first rule if it has more classes-->
					<xsl:when test="$first_rule_class_count &lt; $second_rule_class_count">
						<!--<h3 style="color:darkgreen">$first_rule_class_count &lt; $second_rule_class_count</h3>-->
						<xsl:call-template name="find_most_specific_rule">
							<xsl:with-param name="matching_rules" select="$matching_rules[position() >= 2]"/>
							<xsl:with-param name="current_node" select="$current_node"/>
						</xsl:call-template>
					</xsl:when>
					
					<!--use first rule if it has more classes-->
					<xsl:when test="$first_rule_class_count > $second_rule_class_count">
						<!--<h3 style="color:darkgreen">$first_rule_class_count > $second_rule_class_count</h3>-->
						<xsl:call-template name="find_most_specific_rule">
							<xsl:with-param name="matching_rules" select="$first_rule|$matching_rules[position() > 2]"/>
							<xsl:with-param name="current_node" select="$current_node"/>
						</xsl:call-template>
					</xsl:when>
					
					<!--if id and class counts didn't determine precedence, check if both rules have tags or not-->					
					<!--get rid of the first rule if only second rule has tag-->
					<xsl:when test="$first_rule_tag_count &lt; $second_rule_tag_count">
						<!--<h3 style="color:darkgreen">$first_rule_tag_count &lt; $second_rule_tag_count</h3>-->
						<xsl:call-template name="find_most_specific_rule">
							<xsl:with-param name="matching_rules" select="$matching_rules[position() >= 2]"/>
							<xsl:with-param name="current_node" select="$current_node"/>
						</xsl:call-template>
					</xsl:when>
					
					<!--if only first rule has tag, throw out second rule-->
					<xsl:when test="$first_rule_tag_count > $second_rule_tag_count">
					<!--<h3 style="color:darkgreen">$first_rule_tag_count > $second_rule_tag_count</h3>-->
						<xsl:call-template name="find_most_specific_rule">
							<xsl:with-param name="matching_rules" select="$first_rule|$matching_rules[position() > 2]"/>
							<xsl:with-param name="current_node" select="$current_node"/>
						</xsl:call-template>
					</xsl:when>					
					
					<!--if number of id's, classes, and tags match, use rule's position in structure stylesheet document to determine precedence-->
					<xsl:when test="$first_rule_class_count = $second_rule_class_count">
						<!--<h3 style="color:darkgreen">$first_rule_class_count = $second_rule_class_count</h3>-->
						<!--use second rule-->
						<xsl:call-template name="find_most_specific_rule">
							<xsl:with-param name="matching_rules" select="$matching_rules[position() > 1]"/>
							<xsl:with-param name="current_node" select="$current_node"/>
						</xsl:call-template>			
					</xsl:when>	
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
<!--<h1 style="color:brown"><xsl:value-of select="concat('RULE WAS APPLIED = ', count($matching_rules))"/></h1>	-->
				<!--most specific rule found (yay!); apply it to the current node-->
				<xsl:apply-templates select="$matching_rules/../s:struc" mode="structure_stylesheet">			
					<xsl:with-param name="current_node" select="$current_node"/>
				</xsl:apply-templates>	
				
				<!--if no matching rules, just copy the node-->
				<xsl:if test="not($matching_rules)">
					<xsl:apply-templates select="$current_node" mode="structure_stylesheet"/>	
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>		
		
	</xsl:template>	
	
	<!--
		Templates for adding extra stucture to an element
	-->	
	
	<xsl:template match="@*|node()" mode="structure_stylesheet">
		<xsl:param name="current_node"/>
<!--	<h1 style="color:brown"><xsl:value-of select="concat('node name = ', name($current_node))"/></h1>	-->		
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()" mode="structure_stylesheet">
				<xsl:with-param name="current_node" select="$current_node"/>
			</xsl:apply-templates>
		</xsl:copy>		
	</xsl:template>	
	
	<!--<xsl:template match="s:*" mode="structure_stylesheet">
		<b style="color:brown;font-size:24px;font-famiy:courier new">invalid structure tag: [<xsl:value-of select="name()"/>]</b>
	</xsl:template>
	<xsl:template match="s:rule|s:id|s:class|s:struc" mode="structure_stylesheet"/>-->	
	
	<!--s:struc-->
	<xsl:template match="s:struc" mode="structure_stylesheet">			
		<xsl:param name="current_node"/>
		
		<!--copy stuff inside s:struc-->			
		<xsl:apply-templates select="@*|node()" mode="structure_stylesheet">
			<xsl:with-param name="current_node" select="$current_node"/>
		</xsl:apply-templates>	
	</xsl:template>
	
	<!--s:elem (keep tag name)-->
	<xsl:template match="s:elem" mode="structure_stylesheet">		
		<xsl:param name="current_node"/>
		
		<!--replace s:elem with current node-->		
		<xsl:apply-templates select="$current_node" mode="restructure_current_node_contents">
			<xsl:with-param name="element" select="."/>
		</xsl:apply-templates>		
	</xsl:template>
	
	<!--s:elem (change tag name)-->
	<xsl:template match="s:elem[@s:tag_name]" mode="structure_stylesheet">		
		<xsl:param name="current_node"/>
		
		<!--replace s:elem with current node-->		
		<xsl:apply-templates select="$current_node" mode="restructure_current_node_contents">
			<xsl:with-param name="element" select="."/>
			<xsl:with-param name="tag_name" select="@s:tag_name"/>
		</xsl:apply-templates>		
<!--<h1 style="color:green"><xsl:value-of select="concat('NEW TAG NAME!!!!! = ', @s:tag_name)"/></h1>-->	
	</xsl:template>	
	
	<!--restructure node-->
	<xsl:template match="*" mode="restructure_current_node_contents">			
		<xsl:param name="element"/>
		<xsl:param name="tag_name" select="name()"/>
		<xsl:element name="{$tag_name}">
			<!--update or copy attributes-->
			<xsl:call-template name="update_attributes">		
				<xsl:with-param name="element" select="$element"/>
			</xsl:call-template>
			
			<!--copy contents of s:elem-->
			<xsl:variable name="element_contents" select="$element/node()"/>
			<xsl:apply-templates select="$element_contents" mode="structure_stylesheet">
				<xsl:with-param name="current_node" select="."/>
			</xsl:apply-templates>
			
			<!--copy current node if s:elems is nodeless-->
			<xsl:if test="not($element_contents)">
				<xsl:apply-templates select="." mode="structure_stylesheet"/>
			</xsl:if>
			
		</xsl:element>
<!--<h1 style="color:green"><xsl:value-of select="concat('TAG NAME USED!!!!! = ', $tag_name)"/></h1>-->
	</xsl:template>
	
	<!--s:inner-->
	<xsl:template match="s:inner" mode="structure_stylesheet">		
		<xsl:param name="current_node"/>
		
		<!--replace s:inner placeholder element with actual current node contents (cycle begins again on contents of current node)-->
		<xsl:apply-templates select="$current_node/node()"/>
	</xsl:template>
	
	<!--
		Templates for modifying attributes of an element
	-->
		
	<!--s:attribute (update attributes)-->
	<xsl:template match="@*" mode="update_attributes">
		<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	<xsl:template match="@s:add_classes|@s:tag_name" mode="update_attributes"/>
	
	<!--copy non-updated attributes-->
	<xsl:template match="@*" mode="non_updated_attributes">
		<xsl:param name="attribute_updates"/>
		<xsl:variable name="current_attribute_name" select="name()"/>
		<!--copy attribute if it wasn't updated-->
		<xsl:if test="not($attribute_updates[name() = $current_attribute_name])">
			<xsl:attribute name="{$current_attribute_name}"><xsl:value-of select="."/></xsl:attribute>		
		</xsl:if>		
	</xsl:template>		
	
	<!--update attrubutes (context should be an s:elem node)-->
	<xsl:template name="update_attributes">		
		<xsl:param name="element"/>
		
		<!--update classes-->
		<xsl:variable name="updated_class" select="normalize-space(concat(@class, ' ', $element/@s:add_classes))"/>	
	
		<xsl:if test="$updated_class">
			<xsl:attribute name="class"><xsl:value-of select="$updated_class"/></xsl:attribute>				
		</xsl:if>				
		
		<!--update other attributes-->
		<xsl:variable name="original_attributes" select="@*"/>
		<xsl:variable name="attribute_updates" select="$element/@*"/>
		
		<!--create new and update existing attributes-->			
		<xsl:apply-templates select="$attribute_updates" mode="update_attributes"/>
			
		<!--copy non-updated attributes-->
		<xsl:apply-templates select="$original_attributes" mode="non_updated_attributes">
			<xsl:with-param name="attribute_updates" select="$attribute_updates"/>
		</xsl:apply-templates>			
<!--<h1 style="color:brown"><xsl:value-of select="concat('original_attributes = ', $original_attributes)"/></h1>	-->
	</xsl:template>
		
</xsl:stylesheet>


