<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"   
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:srv="http://www.isotc211.org/2005/srv" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd"  
  xmlns:gml="http://www.opengis.net/gml/3.2" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:r="http://inspire.ec.europa.eu/theme_register"  
  xmlns:gco="http://www.isotc211.org/2005/gco" >
<xsl:output method="text"/>

<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
<xsl:variable name="langCodes" select="document('lang.xml')/language"/>    


<xsl:template match="/">
    <xsl:apply-templates select="//gmd:MD_Metadata"/>
</xsl:template>  

  <!-- for ISO 19139 records -->
<xsl:template match="gmd:MD_Metadata">
<xsl:variable name="apos">'</xsl:variable>
<xsl:variable name="mdlang0" select="normalize-space(gmd:language/gco:CharacterString)"/>
<xsl:variable name="mdlang1" select="normalize-space(gmd:language/*/@codeListValue)"/>
<xsl:variable name="mdlang" select="concat($mdlang0, $mdlang1)" />
<xsl:variable name="mdlang2" select="$langCodes/value[@code=$mdlang]/@code2"/>
<!-- http://inspire.ec.europa.eu/theme/ -->
<xsl:variable name="themes" select="document(concat('theme.', $mdlang2, '.xml'))//r:containeditems"/>    

rec["mdlang2"] = "<xsl:value-of select="$mdlang2"/>";

rec["metadata-party"] = """[<xsl:for-each select="gmd:contact"><xsl:apply-templates select="*"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>]""";

rec["responsible-party1"] = """[<xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact"><xsl:apply-templates select="*"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>]""";

rec["dataset-language"] = """[<xsl:for-each select="gmd:identificationInfo/*/gmd:language">"<xsl:value-of select="normalize-space(*/@codeListValue)"/>"<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>]""";

rec["licence"] = """[<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation">"<xsl:value-of select="normalize-space(*)"/>"<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>]""";

rec["aggregate"] = """[<xsl:for-each select="gmd:identificationInfo/*/gmd:aggregationInfo">"<xsl:value-of select="normalize-space(gmd:MD_AggregateInformation/gmd:aggregateDataSetIdentifier/*/gmd:code/*)"/>"<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>]""";

rec["topic-category"] = """[<xsl:for-each select="gmd:identificationInfo/*/gmd:topicCategory">"<xsl:value-of select="normalize-space(*)"/>"<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>]""";

rec["resource-id"] = """[<xsl:for-each select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier">{"code":"<xsl:value-of select="normalize-space(*/gmd:code/*)"/>","codeSpace":"<xsl:value-of select="normalize-space(*/gmd:codeSpace/*)"/>"}<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>]""";

rec["scales"] = """[<xsl:for-each select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator"><xsl:value-of select="normalize-space(*)"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>]""";

rec["distances"] = """[<xsl:for-each select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:distance"><xsl:value-of select="normalize-space(*)"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>]""";

rec["descriptive-keywords"] = """[<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords">
    {"keywords": [<xsl:for-each select="*/gmd:keyword">
	<xsl:variable name="kw" select="string(*)"/>
        {"label":  <xsl:call-template name="rmulti">
		   				<xsl:with-param name="l" select="$mdlang"/>
		   				<xsl:with-param name="e" select="."/>
		   			</xsl:call-template>,
        
	"uri": <xsl:choose>
            <xsl:when test="*/xlink:href">"<xsl:value-of select="normalize-space(*/xlink:href)"/>"</xsl:when>
		<xsl:when test="starts-with($kw, 'http')">"<xsl:value-of select="normalize-space($kw)"/>"</xsl:when>
		<xsl:when test="contains(../../*/gmd:thesaurusName/*/gmd:title,'INSPIRE')">"<xsl:value-of select="normalize-space($themes/r:theme[r:label=$kw]/@id)"/>"</xsl:when>
		<xsl:otherwise>""</xsl:otherwise>
	</xsl:choose>
	}
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:for-each>],
    "thesaurus": {"title": <xsl:call-template name="rmulti">
		   				<xsl:with-param name="l" select="$mdlang"/>
		   				<xsl:with-param name="e" select="*/gmd:thesaurusName/*/gmd:title"/>
		   			</xsl:call-template>,
        "date": "<xsl:value-of select="normalize-space(string(*/gmd:thesaurusName/*/gmd:date/*/gmd:date))"/>",
        "date-type": "<xsl:value-of select="normalize-space(*/gmd:thesaurusName/*/gmd:date/*/gmd:dateType/*/@codeListValue)"/>"
    }}<xsl:if test="position() != last()">,</xsl:if>
</xsl:for-each>]""";

rec['lineage'] = """<xsl:value-of select='gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement/gco:CharacterString'/>""";

rec["specification"] = """[<xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result">{"title":"<xsl:value-of select="normalize-space(*/gmd:specification/*/gmd:title/gco:CharacterString)"/>","date":"<xsl:value-of select="normalize-space(*/gmd:specification/*/gmd:date/*/gmd:date)"/>","pass":"<xsl:value-of select="normalize-space(*/gmd:pass)"/>"}<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>]""";
</xsl:template>

<xsl:template match="gmd:CI_ResponsibleParty">
{"organisationName": "<xsl:value-of select="normalize-space(gmd:organisationName/gco:CharacterString)"/>",
"individualName": "<xsl:value-of select="normalize-space(gmd:individualName/gco:CharacterString)"/>",
"positionName": "<xsl:value-of select="normalize-space(gmd:positionName/gco:CharacterString)"/>",
"phone": "<xsl:value-of select="normalize-space(gmd:contactInfo/*/gmd:phone/*/gmd:voice)"/>",
"deliveryPoint": "<xsl:value-of select="normalize-space(gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint/gco:CharacterString)"/>",
"city": "<xsl:value-of select="normalize-space(gmd:contactInfo/*/gmd:address/*/gmd:city/gco:CharacterString)"/>",
"postalCode": "<xsl:value-of select="normalize-space(gmd:contactInfo/*/gmd:address/*/gmd:postalCode/gco:CharacterString)"/>",
"country": "<xsl:value-of select="normalize-space(gmd:contactInfo/*/gmd:address/*/gmd:country/gco:CharacterString)"/>",
"email": "<xsl:value-of select="normalize-space(gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress)"/>",
"url": "<xsl:value-of select="normalize-space(gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL)"/>",
"role": "<xsl:value-of select="normalize-space(gmd:role/*/@codeListValue)"/>"}
</xsl:template>

  
<!-- for multilingual elements -->
<xsl:template name="rmulti">
  	<xsl:param name="l"/>
  	<xsl:param name="e"/>
  	<xsl:param name="n"/>"<xsl:value-of select="normalize-space($e/*)"/>"
    <!-- we don't use multiliguality now
    
    {"<xsl:value-of select="normalize-space($langCodes/value[@code=$l]/@code2"/>":"<xsl:value-of select="normalize-space($e/gco:CharacterString)"/>"
  	<xsl:for-each select="$e/gmd:PT_FreeText/*/gmd:LocalisedCharacterString">,
  			<xsl:variable name="l2" select="substring-after(@locale,'-')"/>
		  		"<xsl:value-of select="normalize-space($langCodes/value[@code=$l2]/@code2"/>":"<xsl:value-of select="normalize-space(.)"/>"
  		</xsl:for-each>}-->
</xsl:template>

</xsl:stylesheet>

