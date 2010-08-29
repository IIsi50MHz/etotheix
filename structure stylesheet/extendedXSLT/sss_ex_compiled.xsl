<?xml version="1.0"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="structure-stylesheet" version="1.0" exclude-result-prefixes="s">
  <axsl:output method="html" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
  <axsl:strip-space elements="*"/>
  <axsl:template match="@*|node()">
    <axsl:copy>
      <axsl:apply-templates select="@*|node()"/>
    </axsl:copy>
  </axsl:template>
  
  <!--[START] s:use sss_ex_use.xml-->
  
  <!--s:var-->
  <axsl:variable name="s:xxxxx">WTF</axsl:variable>
  <axsl:variable name="xdsff" select="1234"/>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: www-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'wtf ')]">
    <div>
      <!--s:val-->
      <axsl:value-of select="$s:xxxxx"/>
    </div>
    
    <!--s:this-->
    <axsl:element name="h1">
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:magenta;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates/>
    </axsl:element>
  </axsl:template>
  
  <!--[END] s:use Using sss_ex_use.xml-->
  
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: one-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'one ')]">
    
    <!--s:this-->
    <axsl:copy>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:red;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates/>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: two-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'two ')]">
    
    <!--s:this-->
    <axsl:copy>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:green;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates/>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: three-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'three ')]">
    
    <!--s:this-->
    <axsl:copy>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:blue;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates>
        <axsl:sort order="descending"/>
      </axsl:apply-templates>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: four-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'four ')]">
    
    <!--s:this-->
    <axsl:copy>
      <axsl:for-each select="@*[not(contains('class fourMore ', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:orange; font-style:italic;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates/>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: one-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'five ')]">
    
    <!--s:this-->
    <axsl:copy>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:red;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates mode="id234160"/>
    </axsl:copy>
  </axsl:template>
  
  <!--**************************************************-->
  <!--Auto generated default nested rule-->
  <!--   mode: id234160-->
  <!--**************************************************-->
  <axsl:template match="node()" mode="id234160">
    <axsl:apply-templates select="."/>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: three-->
  <!--   mode: id234160-->
  <!--******************************************-->
  <axsl:template match="li" mode="id234160">
    
    <!--s:this-->
    <axsl:copy>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:blue;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates>
        <axsl:sort order="descending"/>
      </axsl:apply-templates>
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
  <!--   struc: text-->
  <!--**************************************************************************************-->
  <axsl:template match="li/text()[. = 'c' or . = 'a']">
    <span style="color:magenta;">
      
      <!--s:this-->
      <axsl:copy>
        
        <!--s:this atribute-->
        <axsl:attribute name="ding">dongxxx</axsl:attribute>
      </axsl:copy>
    </span>
  </axsl:template>
  <axsl:template match="processing-instruction('xml-stylesheet')"/>
</axsl:stylesheet>
