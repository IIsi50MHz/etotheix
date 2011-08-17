<?xml version="1.0"?>
<!--TODO:
	* make structure stylesheet language a true superset of XSLT
	* make defaults for stuff like xsl:output, but make it easy to override
	* create shorthand for commonly used boilerplate type
	* handle s:use's when used docs have s:use's too
	* think about other things that are confusing or painful in XSLT and make them better. (grouping?)
	done * add code to add/remove a class (s:add-class, s:remove-class)
	done * add ability to use stuff like css(.ding.ding) in match and select
	done * get rid of class('ding')
	no * make it so we can have local named strucs????
	no * make it so we can pass params to strucs when using in rules???? (not sure if we can do this)
	no * class('one two three')	
	no * make it so s:rule and s:inline-struc take <s:struc> wrapper optionally (currently it's required for s:rule and can't be used with s:inline-struc)
		no * or just make s:struc required for s:inline-struc
		no * change @name for s:inline-struc to @struc to make it consistant with s:rule?
		no * ... and change s:inline-struc to just s:inline. <s:inline struc="ding"/>
		* or just get rid of s:struc wapper for s:rule too.
		
	2011.01.11
	done * NOTE: Code for add/remove class is completely wrong. Should probably remove and start over.
	* add html5 compatable doctype to output html
	no * think about changing s:this back to s:elem (s:this seems weird) 
	 	<s:elem>
			<s:add-class>yyy www</s:add-class>
			<s:remove-class>xxx asdf</s:remove-class>
			<s:remove-attr>dong blah</s:remove-attr>
			<s:tag-name>ding</s:tag-name>
		</s:elem>
		
	done * add ability to move elements with id's
		<s:elem>
			<s:relocate id="kong"/>
		</s:elem>
		===
		<xsl:apply-templates select="//s:relocate"/>
		===
		<xsl:key name="elem_by_id" match="*[@id]" use="@id"/>
		...
		<xsl:template select="*[@id='kong']"/> // get rid of original element
		...
		<xsl:apply-templates select="key('elem_by_id', 'kong'") mode="relocate"/> // handle like s:apply-rules
	
	2011.01.29
	done * remove-attr seems to be broken. need to fix.
	fixed * inline-struc doesn't work very well anymore since fixing add-class/remove-class (remove feature?)
	done * need to find a good way to do nested structures? or not.
	done * make these attributes of s:this
		<s:this s:tag-name="ding" s:add-class="a b c" s:remove-class="d e f" s:remove-attr="id"/>
	done * improve s:relocate (move? shift? reposition? grab? yank? put? pop?)
		<s:move id="a" struc="ding"/> 
		<s:move id="a"/>
		<s:move id="a">
			<s:this>
				<ding>abd</ding>
				<apply-rules/>
			</s:this>
		</s:move>
	done * <s:inline-struc name="blah"/> change @name to @struc?
	done * make this work: <s:inline-struc select="xxx"/>
	* create a structure-stylesheet 'validator' (make it so it runs in the browser....)
	* make it easy to turn comments on/off
	* make grouping easy (hide the Muenchian method)
	
-->
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="structure-stylesheet" version="1.0" exclude-result-prefixes="s">
  <axsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
  <axsl:strip-space elements="*"/>
  <axsl:key name="elem_by_id" match="@id/.." use="@id"/>
  <axsl:template match="*[@id = 'ELEPHANT']" priority="1"/>
  <axsl:template match="*[@id = 'relocate_me']" priority="1"/>
  <axsl:template match="@*|node()">
    <axsl:copy>
      <axsl:apply-templates select="@*|node()"/>
    </axsl:copy>
  </axsl:template>
  <axsl:template match="*[not(node())]" priority="0">
    <axsl:copy>
      <axsl:apply-templates select="@*"/>
      <axsl:comment>empty</axsl:comment>
    </axsl:copy>
  </axsl:template>
  <axsl:template match="     area[not(node())]|base[not(node())]|basefont[not(node())]|br[not(node())]|     col[not(node())]|frame[not(node())]|hr[not(node())]|img[not(node())]|     input[not(node())]|isindex[not(node())]|link[not(node())]|meta[not(node())]|     param[not(node())]|nextid[not(node())]|bgsound[not(node())]|embed[not(node())]|     keygen[not(node())]|spacer|wbr[not(node())]" priority="0">
    <axsl:copy-of select="."/>
  </axsl:template>
  
  <!--[START] s:use sss_ex_use.xml-->
  
  <!--s:var-->
  <axsl:variable name="s:xxxxx">WTF</axsl:variable>
  <axsl:variable name="xdsff" select="1234"/>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: www-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(' ', normalize-space(@class), ' '), ' xxx ')]">
    <div>
      <!--s:val-->
      <axsl:value-of select="$s:xxxxx"/>
    </div>
    
    <!--s:this-->
    <h1>
      <axsl:apply-templates select="@*"/>
      
      <!--s:this attribute-->
      <axsl:attribute name="style">color:magenta;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates/>
    </h1>
  </axsl:template>
  
  <!--[END] s:use sss_ex_use.xml-->
  
  <!--<s:struc name="five">		
		<s:this s:tag-name="table" s:add-class="ding dong">
			<tr>
				<s:apply-rules/>
			</tr>
		</s:this>
	</s:struc>
	
	<s:struc name="five_cells">		
		<s:this s:tag-name="td">
			<s:apply-rules/>
		</s:this>
	</s:struc>-->
  <!--HRLEO!!!-->
  <!--
		this is xxx
	-->
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: one-->
  <!--**************************************************************************************-->
  <axsl:template match="div[@id='table'][contains(concat(' ', normalize-space(@class), ' '), ' abc ')][contains(concat(' ', normalize-space(@class), ' '), ' xxx ')][@type='text']">
    
    <!--s:this-->
    <axsl:copy>
      <axsl:apply-templates select="@*"/>
      
      <!--s:apply-rules-->
      <axsl:apply-templates/>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: two-->
  <!--**************************************************************************************-->
  <axsl:template match="ding[*[@id='two'] or *[@id='three']][@blam]">
    
    <!--s:this-->
    <axsl:copy>
      <axsl:apply-templates select="@*"/>
      <axsl:attribute name="class">
        <axsl:call-template name="calculate_class">
          <axsl:with-param name="class" select="concat(' ', normalize-space(@class), ' ')"/>
          <axsl:with-param name="classes_to_remove" select="' qwer asdf '"/>
          <axsl:with-param name="classes_to_add" select="' addedClass addClass2 '"/>
        </axsl:call-template>
      </axsl:attribute>
      
      <!--s:this attribute-->
      <axsl:attribute name="style">color:green;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates/>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: two-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(' ', normalize-space(@class), ' '), ' two ')]">
    
    <!--s:this-->
    <axsl:copy>
      <axsl:apply-templates select="@*"/>
      <axsl:attribute name="class">
        <axsl:call-template name="calculate_class">
          <axsl:with-param name="class" select="concat(' ', normalize-space(@class), ' ')"/>
          <axsl:with-param name="classes_to_remove" select="' qwer asdf '"/>
          <axsl:with-param name="classes_to_add" select="' addedClass addClass2 '"/>
        </axsl:call-template>
      </axsl:attribute>
      
      <!--s:this attribute-->
      <axsl:attribute name="style">color:green;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates/>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: three-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(' ', normalize-space(@class), ' '), ' three ')]">
    
    <!--s:this-->
    <axsl:copy>
      <axsl:apply-templates select="@*"/>
      
      <!--s:this attribute-->
      <axsl:attribute name="style">color:blue;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates>
        <axsl:sort order="descending"/>
      </axsl:apply-templates>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: five-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(' ', normalize-space(@class), ' '), ' five ')]">
    
    <!--s:this-->
    <table>
      <axsl:apply-templates select="@*"/>
      <axsl:attribute name="class">
        <axsl:call-template name="calculate_class">
          <axsl:with-param name="class" select="concat(' ', normalize-space(@class), ' ')"/>
          <axsl:with-param name="classes_to_add" select="' ding dong '"/>
        </axsl:call-template>
      </axsl:attribute>
      <tr>
        
        <!--s:inline-struc-->
        <axsl:for-each select="*">
          
          <!--s:this-->
          <td>
            <axsl:apply-templates select="@*"/>
            <axsl:attribute name="class">
              <axsl:call-template name="calculate_class">
                <axsl:with-param name="class" select="concat(' ', normalize-space(@class), ' ')"/>
                <axsl:with-param name="classes_to_add" select="' HA HO z '"/>
              </axsl:call-template>
            </axsl:attribute>
            
            <!--s:this attribute-->
            <axsl:attribute name="what">is going on?</axsl:attribute>
            
            <!--s:apply-rules-->
            <axsl:apply-templates mode="id199110"/>
          </td>
        </axsl:for-each>
      </tr>
    </table>
  </axsl:template>
  
  <!--**************************************************-->
  <!--Auto generated default nested rule-->
  <!--   mode: id199110-->
  <!--**************************************************-->
  <axsl:template match="node()" mode="id199110">
    <axsl:apply-templates select="."/>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: five_cells-->
  <!--   mode: id199110-->
  <!--******************************************-->
  <axsl:template match="li" mode="id199110"/>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: four-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(' ', normalize-space(@class), ' '), ' four ')]">
    
    <!--s:this-->
    <div>
      <axsl:apply-templates select="@*[not(contains(' id ding dong ', concat(' ', name(), ' ')))]"/>
      <axsl:attribute name="class">
        <axsl:call-template name="calculate_class">
          <axsl:with-param name="class" select="concat(' ', normalize-space(@class), ' ')"/>
          <axsl:with-param name="classes_to_remove" select="' xxx '"/>
        </axsl:call-template>
      </axsl:attribute>
      
      <!--s:this attribute-->
      <axsl:attribute name="style">color:orange; font-style:italic;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates/>
    </div>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: body-->
  <!--**************************************************************************************-->
  <axsl:template match="body">
    
    <!--s:this-->
    <axsl:copy>
      <axsl:apply-templates select="@*"/>
      <axsl:attribute name="class">
        <axsl:call-template name="calculate_class">
          <axsl:with-param name="class" select="concat(' ', normalize-space(@class), ' ')"/>
          <axsl:with-param name="classes_to_add" select="' hello '"/>
        </axsl:call-template>
      </axsl:attribute>
      
      <!--s:move-->
      <axsl:for-each select="key('elem_by_id', 'ELEPHANT')">
        <axsl:copy>
          <axsl:apply-templates select="@*|node()"/>
        </axsl:copy>
      </axsl:for-each>
      
      <!--s:move-->
      <axsl:for-each select="key('elem_by_id', 'relocate_me')">
        <axsl:copy>
          <axsl:apply-templates select="@*|node()"/>
        </axsl:copy>
      </axsl:for-each>
      <div>www</div>
      
      <!--s:inline-struc-->
      <axsl:for-each select="ul">
        <axsl:copy>
          <axsl:apply-templates select="@*|node()"/>
        </axsl:copy>
      </axsl:for-each>
      <div>dings</div>
      <div>ding</div>
      <script>
				//
					alert('&gt;this&lt; is a test &amp; stuff');
				//
			</script>
      
      <!--s:apply-rules-->
      <axsl:apply-templates/>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: div-->
  <!--**************************************************************************************-->
  <axsl:template match="div">
    <tt style="color:magenta;">
      
      <!--s:this-->
      <axsl:copy>
        <axsl:apply-templates select="@*"/>
        
        <!--s:this attribute-->
        <axsl:attribute name="ding">DONG!!!</axsl:attribute>
        
        <!--s:apply-rules-->
        <axsl:apply-templates mode="id199138"/>
      </axsl:copy>
    </tt>
  </axsl:template>
  
  <!--**************************************************-->
  <!--Auto generated default nested rule-->
  <!--   mode: id199138-->
  <!--**************************************************-->
  <axsl:template match="node()" mode="id199138">
    <axsl:apply-templates select="."/>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: xxx-->
  <!--   mode: id199138-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(' ', normalize-space(@class), ' '), ' xxx ')]" mode="id199138">
    <p style="color:pink;">
      
      <!--s:this-->
      <axsl:copy>
        <axsl:apply-templates select="@*"/>
        <axsl:attribute name="class">
          <axsl:call-template name="calculate_class">
            <axsl:with-param name="class" select="concat(' ', normalize-space(@class), ' ')"/>
            <axsl:with-param name="classes_to_add" select="' What the '"/>
          </axsl:call-template>
        </axsl:attribute>
        
        <!--s:apply-rules-->
        <axsl:apply-templates/>
      </axsl:copy>
    </p>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: text-->
  <!--**************************************************************************************-->
  <axsl:template match="li/text()[. = 'c' or . = 'a']">
    <span style="color:magenta;">
      
      <!--s:this-->
      <axsl:copy>
        <axsl:apply-templates select="@*"/>
        
        <!--s:this attribute-->
        <axsl:attribute name="ding">dongxxx</axsl:attribute>
      </axsl:copy>
    </span>
  </axsl:template>
  <axsl:template match="processing-instruction('xml-stylesheet')"/>
  
  <!--**************************************************************************************-->
  <!--* HELPER TEMPLATES-->
  <!--**************************************************************************************-->
  
  <!--Helper Template: replace_string-->
  <axsl:template name="replace_string">
    <axsl:param name="string"/>
    <axsl:param name="replace"/>
    <axsl:param name="with"/>
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
        <axsl:value-of select="$string"/>
      </axsl:otherwise>
    </axsl:choose>
  </axsl:template>
  
  <!--Helper Template: remove_classes-->
  <axsl:template name="remove_classes">
    <axsl:param name="class_attr" select="''"/>
    <axsl:param name="classes" select="''"/>
    <axsl:choose>
      <axsl:when test="normalize-space($classes)">
        <axsl:variable name="current_class" select="concat(' ', substring-before(substring-after($classes, ' '), ' '), ' ')"/>
        <axsl:variable name="updated_class_attr">
          <axsl:call-template name="replace_string">
            <axsl:with-param name="string" select="$class_attr"/>
            <axsl:with-param name="replace" select="$current_class"/>
            <axsl:with-param name="with" select="' '"/>
          </axsl:call-template>
        </axsl:variable>
        <axsl:call-template name="remove_classes">
          <axsl:with-param name="class_attr" select="$updated_class_attr"/>
          <axsl:with-param name="classes" select="concat(' ', substring-after($classes, $current_class))"/>
        </axsl:call-template>
      </axsl:when>
      <axsl:otherwise>
        <axsl:value-of select="normalize-space($class_attr)"/>
      </axsl:otherwise>
    </axsl:choose>
  </axsl:template>
  
  <!--Helper Template: add_classes-->
  <axsl:template name="add_classes">
    <axsl:param name="class_attr" select="''"/>
    <axsl:param name="classes" select="''"/>
    <axsl:choose>
      <axsl:when test="normalize-space($classes)">
        <axsl:variable name="current_class" select="concat(' ', substring-before(substring-after($classes, ' '), ' '), ' ')"/>
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
        <axsl:call-template name="add_classes">
          <axsl:with-param name="class_attr" select="$updated_class_attr"/>
          <axsl:with-param name="classes" select="concat(' ', substring-after($classes, $current_class))"/>
        </axsl:call-template>
      </axsl:when>
      <axsl:otherwise>
        <axsl:value-of select="normalize-space($class_attr)"/>
      </axsl:otherwise>
    </axsl:choose>
  </axsl:template>
  
  <!--Helper Template: calculate_class-->
  <axsl:template name="calculate_class">
    <axsl:param name="class" select="''"/>
    <axsl:param name="classes_to_remove" select="''"/>
    <axsl:param name="classes_to_add" select="''"/>
    <axsl:variable name="classes_removed">
      <axsl:call-template name="remove_classes">
        <axsl:with-param name="class_attr" select="$class"/>
        <axsl:with-param name="classes" select="$classes_to_remove"/>
      </axsl:call-template>
    </axsl:variable>
    <axsl:variable name="classes_added">
      <axsl:call-template name="add_classes">
        <axsl:with-param name="class_attr" select="concat(' ', normalize-space($classes_removed), ' ')"/>
        <axsl:with-param name="classes" select="$classes_to_add"/>
      </axsl:call-template>
    </axsl:variable>
    <axsl:value-of select="$classes_added"/>
  </axsl:template>
</axsl:stylesheet>
