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
    <!--[0www]-->
    <!--hello?-->
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
      <axsl:apply-templates mode="id220324"/>
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
    <!--[1ding]-->
    <!--hello?-->
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
      <axsl:apply-templates mode="id222960"/>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: dong-->
  <!--**************************************************************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'dong ')]">
    <!--[1dong]-->
    <!--hello?-->
    
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
      <axsl:apply-templates mode="id222967"/>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: ul1-->
  <!--**************************************************************************************-->
  <axsl:template match="ul[2]">
    <!--[1ul1]-->
    <!--hello?-->
    
    <!--s:this-->
    <axsl:element name="{name()}">
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:apply-rules-->
      <axsl:apply-templates select="*[contains(concat(normalize-space(@class), ' '), 'one ')]" mode="id222974"/>
      
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
          <axsl:apply-templates mode="id222974"/>
        </axsl:element>
      </axsl:for-each>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************-->
  <!--Auto generated default nested rule-->
  <!--   mode: id222974-->
  <!--**************************************************-->
  <axsl:template match="node()" mode="id222974">
    <axsl:apply-templates select="."/>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: one-->
  <!--   mode: id222974-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'one ')]" mode="id222974">
    <!--[1one]-->
    <!--hello?-->
    
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
      <axsl:apply-templates mode="id222980"/>
    </axsl:element>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: three-->
  <!--   mode: id222974-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'three ')]" mode="id222974">
    <!--[1three]-->
    <!--hello?-->
    
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
      <axsl:apply-templates mode="id222987"/>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************************************************-->
  <!--Top level template for s:rule-->
  <!--   struc: ul2-->
  <!--**************************************************************************************-->
  <axsl:template match="ul[1]">
    <!--[1ul2]-->
    <!--hello?-->
    
    <!--s:this-->
    <axsl:element name="{name()}">
      <axsl:for-each select="@*[not(contains('', concat(name(), ' ')))]">
        <axsl:attribute name="{name()}">
          <axsl:value-of select="."/>
        </axsl:attribute>
      </axsl:for-each>
      
      <!--s:apply-rules-->
      <axsl:apply-templates mode="id222995">
        <axsl:sort order="descending"/>
      </axsl:apply-templates>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************-->
  <!--Auto generated default nested rule-->
  <!--   mode: id222995-->
  <!--**************************************************-->
  <axsl:template match="node()" mode="id222995">
    <axsl:apply-templates select="."/>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: ding-->
  <!--   mode: id222995-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'one ')]" mode="id222995">
    <!--[1ding]-->
    <!--hello?-->
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
      <axsl:apply-templates mode="id223002"/>
    </axsl:element>
  </axsl:template>
  
  <!--**************************************************-->
  <!--Auto generated default nested rule-->
  <!--   mode: id223002-->
  <!--**************************************************-->
  <axsl:template match="node()" mode="id223002">
    <axsl:apply-templates select="."/>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: ding-->
  <!--   mode: id223002-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'xyz ')]" mode="id223002">
    <!--[1ding]-->
    <!--hello?-->
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
      <axsl:apply-templates mode="id223009"/>
    </axsl:element>
  </axsl:template>
  
  <!--******************************************-->
  <!--Nested s:rule-->
  <!--   struc: three-->
  <!--   mode: id222995-->
  <!--******************************************-->
  <axsl:template match="*[contains(concat(normalize-space(@class), ' '), 'three ')]" mode="id222995">
    <!--[1three]-->
    <!--hello?-->
    
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
      <axsl:apply-templates mode="id223017"/>
    </axsl:element>
  </axsl:template>
  <axsl:template match="processing-instruction('xml-stylesheet')"/>
</axsl:stylesheet>
