<?xml version="1.0"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="structure-stylesheet" version="1.0" exclude-result-prefixes="s">
  <axsl:output method="html" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
  <axsl:strip-space elements="*"/>
  <axsl:template match="@*|node()">
    <axsl:copy>
      <axsl:apply-templates select="@*|node()"/>
    </axsl:copy>
  </axsl:template>
  <!--s:var-->
  <axsl:variable name="s:ding">??!HEY!</axsl:variable>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: ding-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'ding ')]">
    <li>
      <!--s:val-->
      <axsl:value-of select="$s:ding"/>
    </li>
    
    <!--s:this-->
    <axsl:element name="{name()}">
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:lightblue;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates mode="id224758"/>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: dong-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'dong ')]">
    
    <!--s:this-->
    <axsl:element name="{name()}">
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:pink;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates mode="id224765"/>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: ul1-->
  <!--**************************************************************************************-->
  <axsl:template match="ul[2]">
    
    <!--s:this-->
    <axsl:element name="{name()}">
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:apply-rules-->
      <axsl:apply-templates select="*[contains(concat(normalize-space(@class), ' '), 'one ')]" mode="id224772"/>
      
      <!--s:inline-struc-->
      <axsl:for-each select="*[not(contains(concat(normalize-space(@class), ' '), 'three '))]">
        
        <!--s:this-->
        <axsl:element name="{name()}">
          <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
            <axsl:attribute name="{name()}">
              <axsl:value-of select="."/>
            </axsl:attribute>
          </axsl:for-each>
          
          <!--s:this atribute-->
          <axsl:attribute name="style">background-color:pink;</axsl:attribute>
          
          <!--s:apply-rules-->
          <axsl:apply-templates mode="id224772"/>
        </axsl:element>
      </axsl:for-each>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************-->
  <!--Auto generated default nested rule (mode: id224772)-->
  <!--**************************************************-->
  <axsl:template match="node()" mode="id224772">
    <axsl:apply-templates select="."/>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: one-->
  <!--   mode: id224779-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'one ')]" mode="id224772">
    
    <!--s:this-->
    <axsl:element name="{name()}">
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:orange;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates mode="id224779"/>
    </axsl:element>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: three-->
  <!--   mode: id224786-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'three ')]" mode="id224772">
    
    <!--s:this-->
    <axsl:element name="{name()}">
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:gray;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates mode="id224786"/>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: ul2-->
  <!--**************************************************************************************-->
  <axsl:template match="ul[1]">
    
    <!--s:this-->
    <axsl:element name="{name()}">
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:apply-rules-->
      <axsl:apply-templates mode="id224794">
        <axsl:sort order="descending"/>
      </axsl:apply-templates>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************-->
  <!--Auto generated default nested rule (mode: id224794)-->
  <!--**************************************************-->
  <axsl:template match="node()" mode="id224794">
    <axsl:apply-templates select="."/>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: ding-->
  <!--   mode: id224801-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'one ')]" mode="id224794">
    <li>
      <!--s:val-->
      <axsl:value-of select="$s:ding"/>
    </li>
    
    <!--s:this-->
    <axsl:element name="{name()}">
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:lightblue;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates mode="id224801"/>
    </axsl:element>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: three-->
  <!--   mode: id227220-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'three ')]" mode="id224794">
    
    <!--s:this-->
    <axsl:element name="{name()}">
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:gray;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates mode="id227220"/>
    </axsl:element>
  </axsl:template>
  <axsl:template match="processing-instruction('xml-stylesheet')"/>
</axsl:stylesheet>
