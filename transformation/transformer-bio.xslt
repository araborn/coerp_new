<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:coerp="http://coerp.uni-koeln.de/schema/coerp"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:import href="tra-header.xslt"/>
    <xsl:import href="tra-texElem.xslt"/>
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <!--Identity template, kopiert Elemente und Attribute, wo keine spezifischere Regel folgt -->
    
    <xsl:template match="/">
        <xsl:apply-templates select="coerp:coerp"/>
    </xsl:template>
    <xsl:template match="coerp:coerp">
        
        <TEI>
            <xsl:namespace name="tei"><xsl:text>http://www.tei-c.org/ns/1.0</xsl:text></xsl:namespace>
            <xsl:text>
            <?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
            <?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?></xsl:text>
            <xsl:call-template name="header"/>
            <xsl:apply-templates/>
        </TEI>
    </xsl:template>
    
    
    <xsl:template match="//coerp:text">       
        <text>
            <body>               
                <xsl:apply-templates/>
            </body>
        </text>
    </xsl:template>
    <xsl:template match="coerp:sample">
        <div>
            <xsl:attribute name="xml:id">
                <xsl:text>sample</xsl:text><xsl:value-of select="@id"/>
            </xsl:attribute>
            
            <xsl:apply-templates  select="child::node()"/>
            
        </div>
    </xsl:template>
    
    
    
    <xsl:template name="text">
        <xsl:analyze-string select="." regex="&#xA;">
            <xsl:matching-substring>
                <lb/><xsl:text>&#xa;</xsl:text>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

</xsl:stylesheet>