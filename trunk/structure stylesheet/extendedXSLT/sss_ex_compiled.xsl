<?xml version="1.0"?>
<!--TODO:
	* make structure stylesheet language a true superset of XSLT
	* handle s:use's when used docs have s:use's too
	* think about other things that are confusing or painful in XSLT and make them better. (grouping?)
	done * add ability to use stuff like css(.ding.ding) in match and select
	done * get rid of class('ding')
	* make it so we can have local named strucs????
	* make it so we can pass params to strucs when using in rules???? (not sure if we can do this)
	no * class('one two three')	
	no * make it so s:rule and s:inline-struc take <s:struc> wrapper optionally (currently it's required for s:rule and can't be used with s:inline-struc)
		no * or just make s:struc required for s:inline-struc
		no * change @name for s:inline-struc to @struc to make it consistant with s:rule?
		no * ... and change s:inline-struc to just s:inline. <s:inline struc="ding"/>
		* or just get rid of s:struc wapper for s:rule too.
-->
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="structure-stylesheet" version="1.0" exclude-result-prefixes="s">
  <axsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
  <axsl:strip-space elements="*"/>
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
  <!--<s:use href="sss_ex_use.xml"/>-->
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: one-->
  <!--**************************************************************************************-->
  <axsl:template match="div[@id='table'][contains(concat(' ', normalize-space(@class), ' '), ' abc ')][contains(concat(' ', normalize-space(@class), ' '), ' xxx ')][@type='text']">
    
    <!--s:inline-struc[@name]-->
    <axsl:for-each select=".">
      
      <!--s:this-->
      <axsl:copy>
        
        <!--s:this attribute-->
        <axsl:attribute name="style">color:green;</axsl:attribute>
        
        <!--s:apply-rules-->
        <axsl:apply-templates/>
      </axsl:copy>
    </axsl:for-each>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: two-->
  <!--**************************************************************************************-->
  <axsl:template match="ding[*[@id='two'] or *[@id='three']][@blam]">
    
    <!--s:this-->
    <axsl:copy>
      
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
  <axsl:template match="*[contains(concat(' ', normalize-space(@class), ' '), ' four ')]">
    
    <!--s:this-->
    <axsl:element name="ol">
      <li>DING!</li>
      
      <!--s:inline-struc-->
      <axsl:for-each select="li">
        <axsl:sort order="descending"/>
        <li>
          
          <!--s:apply-rules-->
          <axsl:apply-templates/>
        </li>
      </axsl:for-each>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: -->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(' ', normalize-space(@class), ' '), ' five ')]">
    
    <!--s:this-->
    <axsl:copy>
      
      <!--s:inline-struc[@name]-->
      <axsl:for-each select="*">
        <axsl:sort order="descending"/>
        
        <!--s:inline-struc[@name]-->
        <axsl:for-each select=".">
          
          <!--s:this-->
          <axsl:copy>
            
            <!--s:this attribute-->
            <axsl:attribute name="style">color:green;</axsl:attribute>
            
            <!--s:apply-rules-->
            <axsl:apply-templates/>
          </axsl:copy>
        </axsl:for-each>
      </axsl:for-each>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: body-->
  <!--**************************************************************************************-->
  <axsl:template match="body">
    
    <!--s:this-->
    <axsl:copy>
      
      <!--s:apply-rules-->
      <axsl:apply-templates>
        <axsl:sort order="descending"/>
      </axsl:apply-templates>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: -->
  <!--**************************************************************************************-->
  <axsl:template match="div">
    
    <!--s:this-->
    <axsl:copy>hello</axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: text-->
  <!--**************************************************************************************-->
  <axsl:template match="li/text()[. = 'c' or . = 'a']">
    <span style="color:magenta;">
      
      <!--s:this-->
      <axsl:copy>
        
        <!--s:this attribute-->
        <axsl:attribute name="ding">dongxxx</axsl:attribute>
      </axsl:copy>
    </span>
  </axsl:template>
  <axsl:template match="processing-instruction('xml-stylesheet')"/>
</axsl:stylesheet>