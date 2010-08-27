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
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:this atribute-->
      <axsl:attribute name="style">color:magenta;</axsl:attribute>
      
      <!--s:apply-rules-->
      <axsl:apply-templates mode="id260717"/>
    </axsl:element>
  </axsl:template>
  
  <!--[END] s:use Using sss_ex_use.xml-->
  
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
      <axsl:apply-templates mode="id263322"/>
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
      <axsl:apply-templates mode="id263329"/>
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
      <axsl:apply-templates select="*[contains(concat(normalize-space(@class), ' '), 'one ')]" mode="id263336"/>
      
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
          <axsl:apply-templates mode="id263336"/>
        </axsl:element>
      </axsl:for-each>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************-->
  <!--Auto generated default nested rule (mode: id263336)-->
  <!--**************************************************-->
  <axsl:template match="node()" mode="id263336">
    <axsl:apply-templates select="."/>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: one-->
  <!--   mode: id263342-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'one ')]" mode="id263336">
    
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
      <axsl:apply-templates mode="id263342"/>
    </axsl:element>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: three-->
  <!--   mode: id263349-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'three ')]" mode="id263336">
    
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
      <axsl:apply-templates mode="id263349"/>
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
      <axsl:apply-templates mode="id263357">
        <axsl:sort order="descending"/>
      </axsl:apply-templates>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************-->
  <!--Auto generated default nested rule (mode: id263357)-->
  <!--**************************************************-->
  <axsl:template match="node()" mode="id263357">
    <axsl:apply-templates select="."/>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: ding-->
  <!--   mode: id263364-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'one ')]" mode="id263357">
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
      <axsl:apply-templates mode="id263364"/>
    </axsl:element>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: three-->
  <!--   mode: id263371-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'three ')]" mode="id263357">
    
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
      <axsl:apply-templates mode="id263371"/>
    </axsl:element>
  </axsl:template>
  <axsl:template match="processing-instruction('xml-stylesheet')"/>
</axsl:stylesheet>
