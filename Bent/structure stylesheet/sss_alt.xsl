<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:s="structure_stylesheet"
	xmlns:h="http://www.w3.org/1999/xhtml"
>  
	<xsl:output method="html" indent="yes"/>

	<!--grab all structure stylesheets-->
	<xsl:variable name="structure_stylesheet_filename" select="/h:html/h:head/h:link[@type='xml/sss']/@href"/>
	<xsl:variable name="structure_stylesheets" select="document($structure_stylesheet_filename)/*"/>
	<!--grab all structure stylesheet rules-->
	<xsl:variable name="rules" select="$structure_stylesheets/s:rule"/>
	<xsl:variable name="sels" select="$rules/s:sel"/>
	<xsl:variable name="num_sels" select="count($sels)"/>

	<!--
		Identity transform (what comes in goes out)
	-->	
	<xsl:template match="/|@*|node()">
		<xsl:copy>			
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>		
	</xsl:template>

	<!--process all element nodes-->
	<xsl:template match="*">
		<!--apply rule with highest precedence-->

	</xsl:template>

	<!--find highest prececence rule-->

	<!--gather all matching rules for a given node-->	
	<xsl:template name="gather_sels">		
		<xsl:param name="gathered_sels"/>
		<xsl:param name="sel_index"/>
		<xsl:param name="sel"/>
		<xsl:param name="sel_string"/>	
		<xsl:param name="current_elem"/>	
		<xsl:param name="id_string" select="string(@id)"/>		
		<xsl:param name="tag_string" select="name()"/>
		<xsl:param name="class_string" select="normalize-space(@class)"/>		
		<xsl:param name="attr_nodes" select="@*"/>

		<!--figure out if current selector is match-->
		<xsl:variable name="sel_is_match">
			<xsl:call-template name="test_sel">				
				<xsl:with-param name="sel_string" select="$sel_string"/>				
				<xsl:with-param name="id_string" select="$id_string"/>
				<xsl:with-param name="tag_string" select="$tag_string"/>
				<xsl:with-param name="class_string" select="$class_string"/>
				<xsl:with-param name="attr_nodes" select="$attr_nodes"/>
			</xsl:call-template>
		</xsl:variable>		

		<xsl:variable name="next_sel_index" select="$sel_index + 1"/>
		<xsl:choose>
			<xsl:when test="$next_sel_index &lt; $num_sel">								
				<xsl:variable name="next_sel" select="$sels[$next_sel_index]"/>
				<!--add current selector to collection if it's match; look at next selector-->
				<xsl:call-template name="gather_sels">
					<xsl:with-param name="gathered_sels" select="$gathered_sels|sel[$sel_is_match]"/>
					<xsl:with-param name="sel_index" select="$next_sel_index"/>
					<xsl:with-param name="sel" select="$sels[$next_sel_index]"/>
					<xsl:with-param name="sel_string" select="string($next_sel)"/>
					<xsl:with-param name="current_elem" select="$current_elem"/>
					<xsl:with-param name="id_string" select="$id_string"/>
					<xsl:with-param name="tag_string" select="$tag_string"/>
					<xsl:with-param name="class_string" select="$class_string"/>
					<xsl:with-param name="attr_nodes" select="$attr_nodes"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!--all matching selector gathered; find selector with hightes precedence-->
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<!--**TODO: think about getting rid of this and just do a straight call to test_id_sel-->
	<xsl:template name="test_sel">
		<xsl:param name="sel_string"/>				
		<xsl:param name="id_string"/>
		<xsl:param name="tag_string"/>
		<xsl:param name="class_string"/>
		<xsl:param name="attr_nodes"/>

		<!--start test with id selector; if id selector is a match, this will continue on to test other selectors-->
		<xsl:call-template name="test_id_sel">	
			<xsl:with-param name="sel_string"/>				
			<xsl:with-param name="id_string"/>
			<xsl:with-param name="tag_string"/>
			<xsl:with-param name="class_string"/>
			<xsl:with-param name="attr_nodes"/>
		</xsl:call-template>
	</xsl:template>

	<!--check if selector matches id-->
	<xsl:template name="test_id_sel">
		<xsl:param name="sel_string"/>				
		<xsl:param name="id_string"/>
		<xsl:param name="tag_string"/>
		<xsl:param name="class_string"/>
		<xsl:param name="attr_nodes"/>		

		<xsl:variable name="sel_has_no_id" select="not(contains($sel_string, '#'))"/>		
		<!--
			The second half of the if test below is pretty messy. Here's what's going on:						
				// reformat selector string to guarantee id is sandwiched between a "#" and a "?"
				$reform_sel_string := concat(translate($sel_string, '.[', '??'), '?')
				// extract id from reformated substring
				$substring-before(substring-after($reform_sel_string, '#'), '?')
		-->
		<xsl:if test="$sel_has_no_id or $id_string = $substring-before(substring-after(concat(translate($sel_string, '.[', '??'), '?'), '#'), '?')">
			<!--id sel matches; check tag sel-->
			<xsl:call-template name="test_tag_sel">
				<xsl:with-param name="sel_string"/>				
				<xsl:with-param name="tag_string"/>
				<xsl:with-param name="class_string"/>
				<xsl:with-param name="attr_nodes"/>
			</xsl:call-template>
		</xsl:if>		
	</xsl:template>

	<!--check if selector matches tag-->
	<xsl:template name="test_tag_sel">
		<xsl:param name="sel_string"/>		
		<xsl:param name="tag_string"/>
		<xsl:param name="class_string"/>
		<xsl:param name="attr_nodes"/>										

		<xsl:variable name="reform_sel_string" select="concat(translate($sel_string, '.#[', '???'), '?')"/>
		<!--check if selector has a tag-->
		<xsl:variable name="sel_has_no_tag" select="starts-with($reform_sel_string, '?')"/>
		<xsl:if test="$sel_has_no_tag or $tag_string = substring-before($reform_sel_string, '?'))">
			<!--tag sel matches; check class sel-->
			<xsl:call-template name="test_class_sel">
				<xsl:with-param name="sel_string"/>				
				<xsl:with-param name="class_string"/>
				<xsl:with-param name="attr_nodes"/>
			</xsl:call-template>
		</xsl:if>		
	</xsl:template>

	<!--check if selector matches classes-->
	<xsl:template name="test_class_sel">
		<xsl:param name="sel_string"/>				
		<xsl:param name="class_string"/>
		<xsl:param name="attr_nodes"/>	

		<xsl:variable name="sel_has_no_class" select="contains($sel_string, '.')"/>

		<xsl:choose>
			<xsl:when test="$sel_has_no_class">
				<!--class sel matches; check attr sel-->
				<xsl:call-template name="test_attr_sel">
					<xsl:with-param name="sel_string"/>									
					<xsl:with-param name="attr_nodes"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!--
					trim start of selector up to first class
					replace # and ['s with ?'s
					add .? to end
					
					e.g. class1?blah?a=b].class2.class3?c].?				
				-->
				<xsl:variable name="reform_sel_string" select="concat(translate(substring-after($sel_string, '.'), '#[', '??'), '?')"/>
				<xsl:variable name="all_classes_match">
					<xsl:call-template name="check_classes">
						<xsl:with-param name="reform_sel_string" select="$reform_sel_string"/>
						<xsl:with-param name="class_string" select="$class_string"/>					
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="$all_classes_match">
					<!--all class sel match; check all attr sel-->
					<xsl:call-template name="test_attr_sel">
						<xsl:with-param name="sel_string"/>									
						<xsl:with-param name="attr_nodes"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>			

	<xsl:template name="check_classes">		
		<xsl:param name="reform_sel_string"/>		
		<xsl:param name="class_string"/>		

		<!--one of these substrings will be empty, the other will be the current class-->
		<xsl:variable name="current_class" select="concat(
			substring-before(substring-before($reform_sel_string, '.'), '?'), 
			substring-before(substring-before($reform_sel_string, '?'), '.') 
		)"/>			

		<!--check if elem class contains current class selector-->
		<xsl:if select="contains($class_string, $current_class)">							
			<xsl:variable name="next_reform_sel_string" select="$substring-after($reform_sel_string, '.')"/>
			<xsl:choose>				
				<!--see if there are any classes left to check-->
				<xsl:when test="$next_reform_sel_string">					
					<xsl:call-template name="check_classes">
						<xsl:with-param name="reform_sel_string" select="$next_reform_sel_string"/>
						<xsl:with-param name="class_string" select="$class_string"/>						
					</xsl:call-template>
				</xsl:when>				
				<!--all class selectors match!-->
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>		
		</xsl:if>		
	</xsl:template>

	<xsl:template name="test_attr_sel">
		<xsl:param name="sel_string"/>
		<xsl:param name="attr_nodes"/>	
		
		<xsl:variable name="sel_has_no_attr" select="not(contains($sel_string, '['))"/>
		<xsl:choose>
			<!--entire selector matches!!!-->
			<xsl:when test="sel_has_no_attr">true</xsl:when>
			<!--check for attr match-->
			<xsl:otherwise>			
				<xsl:call-template name="check_attr">
					<xsl:with-param name="reform_sel_string" select="substring-after($sel_string, '[')"/>
					<xsl:with-param name="attr_nodes" select="$attr_nodes"/>						
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:call-template name="check_attr">
		<xsl:param name="reform_sel_string"/>
		<xsl:param name="attr_nodes"/>
		
		<xsl:variable name="current_attr_name" select="substring-before(translate($sel_string, '=', ']'), ']')"/>		
		<xsl:variable name="current_attr_val" select="substring-before(substring-after($sel_string, '='), ']')"/>
		<xsl:variable name="attr_has_val" select="contains($sel_string, '=')"/>		
		
		<!--
			check if elem attr match current attr selector		
				first line checks for name only selector match, e.g. [name]
				second line checks for name and value selector match, e.g. [name=val]
		-->
		<xsl:if select="
			not($attr_has_val) and $attr_nodes[name() = $current_attr_name] or
			$attr_has_val and $attr_nodes[name() = $current_attr_name and . = $current_attr_val]			
		">							
			<xsl:variable name="next_reform_sel_string" select="$substring-after($reform_sel_string, '[')"/>
			<xsl:choose>				
				<!--see if there are any classes left to check-->
				<xsl:when test="$next_reform_sel_string">					
					<xsl:call-template name="check_attr">
						<xsl:with-param name="reform_sel_string" select="$next_reform_sel_string"/>
						<xsl:with-param name="attr_nodes" select="$attr_nodes"/>						
					</xsl:call-template>
				</xsl:when>				
				<!--entire selector matches!-->
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>		
		</xsl:if>		
	</xsl:call-template>

</xsl:stylesheet>