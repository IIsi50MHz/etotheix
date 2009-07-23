<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet 
	version="1.0" 	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:output method="html" indent="yes"/>	
	<!--NODE MANIPULATION EXAMPLES-->
	<xsl:template match="tag">	
		<!--EX: how to change a tag's name-->		
		<!--create new tag-->
		<new_tag_name>
			<!--copy original tag attributes and contents to new tag (original tag not copied)-->
			<xsl:apply-templates select="@*|node()"/>				
		</new_tag_name>

		<!--EX: how to add stuff inside a tag-->				
		<!--copy original tag-->
		<xsl:copy>	
			<!--add stuff-->
			<inside_stuff_added>inside stuff!</inside_stuff_added>
			<!--copy original tag contents-->
			<xsl:apply-templates select="@*|node()"/>		
		</xsl:copy>	

		<!--EX: how to wrap a tag-->		
		<!--create wrapper tag-->
		<wrapper_tag>
			<!--copy original tag-->
			<xsl:copy>				
				<!--copy original tag contents-->
				<xsl:apply-templates select="@*|node()"/>		
			</xsl:copy>		
		</wrapper_tag>

		<!--EX: how to wrap the contents of a tag-->				
		<!--copy original tag-->
		<xsl:copy>
			<!--copy attributes to tag copy-->
			<xsl:apply-templates select="@*"/>
			<!--create inside wrapper tag-->
			<inside_wrapper>
				<!--copy original tag contents to inside wrapper-->
				<xsl:apply-templates select="node()"/>
			</inside_wrapper>
		</xsl:copy>		

		<!--EX: how to wrap a tag and steal it's attributes-->		
		<!--create wrapper tag-->
		<wrapper_tag_steals_attr>
			<!--copy original tag attributes to new tag-->
			<xsl:apply-templates select="@*"/>
			<!--copy original tag minus it's attributess-->
			<xsl:copy>				
				<xsl:apply-templates select="node()"/>			
			</xsl:copy>			
		</wrapper_tag_steals_attr>	

		<!--EX: how to wrap the contents of a tag and steal it's attributes-->				
		<!--copy original tag-->
		<xsl:copy>			
			<!--create inside wrapper tag-->
			<inside_wrapper_steals_attr>
				<!--copy original tag attributes and contents to inside wrapper-->
				<xsl:apply-templates select="@*|node()"/>
			</inside_wrapper_steals_attr>			
		</xsl:copy>					
	</xsl:template>
</xsl:stylesheet>