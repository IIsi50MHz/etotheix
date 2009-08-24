<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:s="structure_stylesheet"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:blah="asdf"
>
	<xsl:output method="html" indent="yes"/>

	<!--grab all structure stylesheets-->
	<xsl:variable name="structure_stylesheet_filename" select="/*/*/s:use_structure_stylesheet"/>
	<xsl:variable name="structure_stylesheet" select="document($structure_stylesheet_filename)/*"/>
	<xsl:variable name="xxx" select="//blah:head"/>
	<!--grab all structure stylesheet rules-->
	<xsl:variable name="rules" select="$structure_stylesheet/s:rule"/>
	<!--key for grabbing all struc_rules that have a given id (key('id', 'anIdName')/..)-->
	<xsl:key name="rule_id" match="s:id" use="."/>
	<!--key for grabbing all struc_rules that have a given class (key('class', 'aClassName')/..)-->
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
		<div>
		---------------------------@*|node() (<xsl:value-of select="name(.)"/>)	
		</div>			
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>		
	</xsl:template>	
		
	<xsl:template match="s:use_structure_stylesheet" mode="structure_stylesheet"/>
	
	<!--
		Templates gathering structure stylesheet rules
	-->
	
	<!--**TODO?: add match for tag name in addition to id and class-->	
	<xsl:template match="*[@id|@class]">	
		<div>
		*[@id|@class] (<xsl:value-of select="name(.)"/>)(<xsl:value-of select="."/>)	
		</div>
		<!--apply structure stylesheet to current node-->	
		<xsl:apply-templates select="$structure_stylesheet" mode="structure_stylesheet">
			<xsl:with-param name="id_string" select="normalize-space(@id)"/>
			<!--ensure every class name in class string has exactly one space after it-->
			<xsl:with-param name="class_string" select="concat(normalize-space(@class), ' ')"/>
			<xsl:with-param name="current_node" select="."/>				
		</xsl:apply-templates>		
	</xsl:template>
	
	<!--structure stylesheet-->
	<xsl:template match="s:structure_stylesheet" mode="structure_stylesheet">		
		<xsl:param name="class_string"/>
		<xsl:param name="id_string"/>
		<xsl:param name="current_node"/>
		<div>
		s:structure_stylesheet (<xsl:value-of select="name($current_node)"/>) (<xsl:value-of select="$current_node"/>)	
		</div>	
		
		<!--try to find a matching rule-->					
		<xsl:choose>			
			
			<!--check for a matching id rule-->
			<xsl:when test="$id_string">
				
				<!--grab rules matching id-->
				<xsl:variable name="matching_id_rules" select="key('rule_id', $id_string)/.."/>
				
				<!--keep going if there are any matches-->
				<xsl:if test="$matching_id_rules">			
					<xsl:call-template name="gather_matching_rules">
						<xsl:with-param name="class_string" select="$class_string"/>		
						<xsl:with-param name="matching_rules" select="$matching_id_rules"/>
						<xsl:with-param name="current_node" select="$current_node"/>
					</xsl:call-template>
				</xsl:if>
				
			</xsl:when>
		
			<!--check for a matching class rule-->
			<xsl:when test="$class_string">
				
				<!--pluck out first class name-->
				<xsl:variable name="class_name" select="substring-before($class_string, ' ')"/>
				
				<!--grab rules matching class name-->
				<xsl:variable name="matching_class_rules" select="key('rule_class', $class_name)/.."/>
				
				<!--keep going if there are any matches-->
				<xsl:if test="$matching_class_rules">
					<xsl:call-template name="gather_matching_rules">
						<xsl:with-param name="class_string" select="$next_class_string"/>	
						<xsl:with-param name="matching_rules" select="$matching_class_rules"/>
						<xsl:with-param name="current_node" select="$current_node"/>
					</xsl:call-template>
				</xsl:if>				
				
			</xsl:when>			
		</xsl:choose>			
	</xsl:template>		
	
	<!--gather matching rules-->
	<xsl:template name="gather_matching_rules">		
		<xsl:param name="class_string"/>
		<xsl:param name="matching_rules"/>	
		<xsl:param name="current_node"/>	
		<xsl:variable name="class_name" select="substring-before($class_string, ' ')"/>
		<div>
		name="gather_matching_rules" (<xsl:value-of select="name($current_node)"/>) (<xsl:value-of select="$current_node"/>)	
		</div>	
		<!--grab the union of rules that have matched so far with the rules that match the current class-->
		<xsl:variable name="gathered_matching_rules" select="$matching_rules|key('rule_class', $class_name)/.."/>
		
		<!--if there are any classes left, continue gathering matching rules-->
		<xsl:if test="$class_string">
			<xsl:call-template name="gather_matching_rules">
				<xsl:with-param name="class_string" select="substring-after"/>
				<xsl:with-param name="matching_rules" select="$gathered_matching_rules"/>
				<xsl:with-param name="current_node" select="$current_node"/>
			</xsl:call-template>
		</xsl:if>
		
		<!--**TODO?: check for matching tags-->
		
		<!--once we've got all the matching rules, find most specific matching rule-->
		<xsl:call-template name="find_most_specific_rule">
			<xsl:with-param name="matching_rules" select="$matching_rules"/>			
			<xsl:with-param name="current_node" select="$current_node"/>
		</xsl:call-template>
				
	</xsl:template>
	
	<!--find most specific rule-->
	<xsl:template name="find_most_specific_rule">			
		<xsl:param name="matching_rules"/>		
		<xsl:param name="current_node"/>		
		<div>
		name="find_most_specific_rule" (<xsl:value-of select="name($current_node)"/>) (<xsl:value-of select="$current_node"/>)	
		</div>	
		
		<!--see if there's more than one rule--> 
		<xsl:if test="count($matching_rules) > 1">		
			<!--grab first two rules-->
			<xsl:variable name="first_rule" select="$matching_rules[position() = 1]"/>
			<xsl:variable name="second_rule" select="$matching_rules[position() = 2]"/>
			
			<!--see if first two rules have an id-->
			<xsl:variable name="first_id_count" select="count(first_matching_rule[id])"/>
			<xsl:variable name="second_id_count" select="count(second_matching_rule[id])"/>			
			
			<!--figure out which of the first two rules has the highest precedence-->
			
			<!--get rid of the first rule if only second rule has id-->
			<xsl:if test="$first_id_count &lt; $second_id_count">
				<xsl:call-template name="find_most_specific_rule">
					<xsl:with-param name="matching_rules" select="$matching_rules[position >= 2]"/>
					<xsl:with-param name="current_node" select="$current_node"/>
				</xsl:call-template>
			</xsl:if>
			
			<!--if only first rule has id, throw out second rule-->
			<xsl:if test="$first_id_count > $second_id_count">
				<xsl:call-template name="find_most_specific_rule">
					<xsl:with-param name="matching_rules" select="$first_rule|$matching_rules[position > 2]"/>
					<xsl:with-param name="current_node" select="$current_node"/>
				</xsl:call-template>
			</xsl:if>			
			
			<!--if id count didn't determine precedence, compare number of classes-->
						
			<!--count classes-->
			<xsl:variable name="first_class_count" select="count(first_matching_rule[class])"/>
			<xsl:variable name="second_class_count" select="count(second_matching_rule[class])"/>
			
			<!--use first rule if it has more classes-->
			<xsl:if test="$first_class_count &lt; $second_class_count">
				<xsl:call-template name="find_most_specific_rule">
					<xsl:with-param name="matching_rules" select="$matching_rules[position >= 2]"/>
					<xsl:with-param name="current_node" select="$current_node"/>
				</xsl:call-template>
			</xsl:if>
			
			<!--use second rule if it has more classes-->
			<xsl:if test="$first_class_count > $second_class_count">
				<xsl:call-template name="find_most_specific_rule">
					<xsl:with-param name="matching_rules" select="$first_rule|$matching_rules[position > 2]"/>
					<xsl:with-param name="current_node" select="$current_node"/>
				</xsl:call-template>
			</xsl:if>
			
			<!--if number of id's and number of classes match, use rule's position in structure stylesheet document to determine precedence-->
			<xsl:if test="$first_class_count = $second_class_count">
				<!--get position of rules in structure stylesheet-->
				<xsl:variable name="first_class_rule_id" select="generate-id($first_rule)"/>
				<xsl:variable name="second_class_rule_id" select="generate-id($second_rule)"/>
				<xsl:variable name="first_class_rule_doc_position" select="position($rules[$first_class_rule_id = generate-id(.)])"/>
				<xsl:variable name="second_class_rule_doc_position" select="position($rules[$second_class_rule_id = generate-id(.)])"/>
				
				<!--use first rule-->
				<xsl:if test="first_class_rule_doc_position > second_class_rule_doc_position">
					<xsl:call-template name="find_most_specific_rule">
						<xsl:with-param name="matching_rules" select="$first_rule|$matching_rules[position > 2]"/>
						<xsl:with-param name="current_node" select="$current_node"/>
					</xsl:call-template>
				</xsl:if>

				<!--use second rule-->
				<xsl:call-template name="find_most_specific_rule">
					<xsl:with-param name="matching_rules" select="$matching_rules[position > 1]"/>
					<xsl:with-param name="current_node" select="$current_node"/>
				</xsl:call-template>			
			</xsl:if>										
		</xsl:if>
		
		<!--most specific rule found (yay!); apply it to the current node-->
		<xsl:apply-templates select="$matching_rules/s:restructure" mode="structure_stylesheet">			
			<xsl:with-param name="current_node" select="$current_node"/>
		</xsl:apply-templates>	
		
	</xsl:template>		
	
	<!--
		Templates for adding extra stucture to an element
	-->	
	
	<xsl:template match="@*|node()" mode="structure_stylesheet">
		<xsl:param name="current_node"/>
		<div>
		xxxxxxxxxxxxxxxxxxxxxxxxxxx@*|node() (<xsl:value-of select="name($current_node)"/>)	(<xsl:value-of select="$current_node"/>)
		</div>			
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()" mode="structure_stylesheet">
				<xsl:with-param name="current_node" select="$current_node"/>
			</xsl:apply-templates>
		</xsl:copy>		
	</xsl:template>	
	
	<xsl:template match="s:rule|s:id|s:class|s:restructure|s:attribute" mode="structure_stylesheet"/>		
	
	<!--s:restructure-->
	<xsl:template match="s:restructure" mode="structure_stylesheet">			
		<xsl:param name="current_node"/>
		<div>
		s:restructure (<xsl:value-of select="name($current_node)"/>) (<xsl:value-of select="$current_node"/>)	
		</div>
		<!--copy stuff inside s:restructure-->			
		<xsl:apply-templates select="@*|node()" mode="structure_stylesheet">
			<xsl:with-param name="current_node" select="$current_node"/>
		</xsl:apply-templates>	
	</xsl:template>
	
	<!--s:element (keep tag name)-->
	<xsl:template match="s:element" mode="structure_stylesheet">		
		<xsl:param name="current_node"/>
		<div>
		s:element (<xsl:value-of select="name($current_node)"/>) (<xsl:value-of select="$current_node"/>)	
		</div>
		<!--replace s:element with current node-->
		%%%%%%%%%%%%
		
		
		<xsl:apply-templates select="$current_node" mode="restructure_current_node_contents">
			<xsl:with-param name="element" select="."/>
		</xsl:apply-templates>
		
	</xsl:template>	
	
	<xsl:template match="*" mode="restructure_current_node_contents">			
		<xsl:param name="element"/>
		<div>$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
		* mode="restructure_current_node_contents" (<xsl:value-of select="name(.)"/>) (<xsl:value-of select="."/>)	
		</div>
		<xsl:copy>		5656565656
			<!--update or copy attributes-->
			
			<!--copy contents of s:element-->	
			<xsl:apply-templates select="$element/*" mode="structure_stylesheet">
				<xsl:with-param name="current_node" select="."/>
			</xsl:apply-templates>
			565656565656
		</xsl:copy>
	</xsl:template>
	
	<!--s:contents-->
	<xsl:template match="s:contents" mode="structure_stylesheet">		
		<xsl:param name="current_node"/>
		<div>??????????????????
		_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_s:contents (<xsl:value-of select="name($current_node)"/>) (<xsl:value-of select="$current_node"/>)	
		</div>????????????????[
		<!--replace s:contents placeholder element with actual current node contents (cycle begins again on contents of current node)-->
		<xsl:apply-templates select="$current_node/node()"/>
		(<xsl:value-of select="$current_node"/>)]???????????????????			
	</xsl:template>
	
	<!--
		Templates for modifying attributes of an element
	-->
		
	<!--s:attribute (update attributes)-->
	<xsl:template match="s:attribute|@*" mode="update_attributes">
		<xsl:attribute name="class"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	
	<!--copy non-updated attributes-->
	<xsl:template match="@*" mode="non_updated_attributes">
		<xsl:param name="attribute_updates"/>
		<xsl:variable name="current_attribute_name" select="name()"/>
		<xsl:if test="$attribute_updates[name() = $current_attribute_name]">
			<xsl:apply-templates select="." mode="update_attributes"/>
		</xsl:if>
	</xsl:template>	
	
	<!--update attrubutes (context should be an s:element node)-->
	<xsl:template name="update_attributes">		
		<xsl:param name="current_node"/>
		
		<!--update classes-->
		<xsl:variable name="updated_class" select="normalize-space(concat($current_node/@class, ' ', @add_classes))"/>
		<xsl:if test="$updated_class">
			<xsl:attribute name="class"><xsl:value-of select="$updated_class"/></xsl:attribute>
		</xsl:if>				
		
		<!--update other attributes-->
		<xsl:variable name="original_attributes" select="$current_node/@*[name() != 'class']"/>
		<xsl:variable name="attribute_updates" select="s:attribute[name() != 'class']"/>
		
		<!--create new and update existing attributes-->			
		<xsl:apply-templates select="$attribute_updates" mode="update_attributes"/>
			
		<!--copy non-updated attributes-->
		<xsl:apply-templates select="$original_attributes" mode="non_updated_attributes">
			<xsl:with-param name="attribute_updates" select="$attribute_updates"/>
		</xsl:apply-templates>				
	</xsl:template>
	
	<!--
		Cycle begins again on contents of current node
	-->
	
	
		
</xsl:stylesheet>


