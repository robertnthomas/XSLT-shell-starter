<?xml version="1.0" encoding="UTF-8" ?>
<!-- Copyright Tagsmiths, LLC July 2017 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:ts="https://tagsmiths.com/xslt"
    exclude-result-prefixes="xs ts dita-ot">

    <!-- Tagsmiths: Unchanged. Copied for template precedence reasons. 31aug17 -->
  <xsl:template match="dita-merge/*[contains(@class, ' map/map ')]" mode="build-tree">
    <opentopic:map xmlns:opentopic="http://www.idiominc.com/opentopic">
      <xsl:apply-templates/>
    </opentopic:map>
    <xsl:apply-templates mode="build-tree"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="build-tree">
        <!-- Tagsmiths: Construct an ancestry string.  -->
        <xsl:param name="incomingDivNumber"/>
        <xsl:variable name="bookancestry">
            <xsl:variable name="bookAncestorsUnstripped">
                <xsl:for-each select="ancestor-or-self::*[position() &lt; last()]">
                    <xsl:value-of select="ts:getOriginalElementName(@class)">
                    </xsl:value-of>
                    <xsl:text>:</xsl:text>
                </xsl:for-each>
                <xsl:choose>
                    <!-- Include current element if it's a chapter with an active href -->
                    <xsl:when
                        test="
                            .[contains(@class, ' bookmap/chapter ')] and
                            (
                            not(normalize-space(@href) = '') or
                            @navtitle or
                            *[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]
                            )">
                        <xsl:text>CHAPTER:</xsl:text>
                    </xsl:when>
                    <!-- Include current element if it's an apprendix with an active href -->
                    <xsl:when
                        test="
                            .[contains(@class, ' bookmap/appendix ')] and
                            (
                            not(normalize-space(@href) = '') or
                            @navtitle or
                            *[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]
                            )">
                        <xsl:text>APPENDIX:</xsl:text>
                    </xsl:when>
                    <!-- Include current element if it's a part with an active href -->
                    <xsl:when
                        test="
                            .[contains(@class, ' bookmap/part ')] and
                            (
                            not(normalize-space(@href) = '') or
                            @navtitle or
                            *[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]
                            )">
                        <xsl:text>PART:</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <!-- Strip the trailing : character  -->
            <xsl:value-of
                select="substring($bookAncestorsUnstripped, 1, string-length($bookAncestorsUnstripped) - 1)"
            />
        </xsl:variable>
        <!-- Tagsmiths: Compute the sequence number. -->
        <xsl:variable name="seqNumber">
            <xsl:call-template name="getNumber">
                <xsl:with-param name="divNumber" select="$incomingDivNumber"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="currentDivNumber">
            <xsl:choose>
                <xsl:when
                    test="ends-with($bookancestry, 'CHAPTER') or ends-with($bookancestry, 'APPENDIX')">
                    <xsl:call-template name="getNumber"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$incomingDivNumber"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(normalize-space(@first_topic_id) = '')">
                <xsl:apply-templates select="key('topic', @first_topic_id)">
                    <xsl:with-param name="parentId" select="generate-id()"/>
                    <xsl:with-param name="bookancestry" select="$bookancestry"/>
                    <xsl:with-param name="seqNumber" select="$seqNumber"/>
                    <xsl:with-param name="incomingDivNumber" select="$currentDivNumber"/>
                </xsl:apply-templates>
                <xsl:if test="@first_topic_id != @href">
                    <xsl:apply-templates select="key('topic', @href)">
                        <xsl:with-param name="parentId" select="generate-id()"/>
                        <xsl:with-param name="bookancestry" select="$bookancestry"/>
                        <xsl:with-param name="seqNumber" select="$seqNumber"/>
                        <xsl:with-param name="incomingDivNumber" select="$currentDivNumber"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="not(normalize-space(@href) = '')">
                <xsl:apply-templates select="key('topic', @href)">
                    <xsl:with-param name="parentId" select="generate-id()"/>
                    <xsl:with-param name="bookancestry" select="$bookancestry"/>
                    <xsl:with-param name="seqNumber" select="$seqNumber"/>
                    <xsl:with-param name="incomingDivNumber" select="$currentDivNumber"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when
                test="
                    contains(@class, ' bookmap/part ') or
                    (normalize-space(@navtitle) != '' or
                    *[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')])
                    ">
                <xsl:variable name="isNotTopicRef" as="xs:boolean">
                    <xsl:call-template name="isNotTopicRef"/>
                </xsl:variable>
                <xsl:if test="not($isNotTopicRef)">
                    <topic id="{generate-id()}" class="+ topic/topic pdf2-d/placeholder ">
                        <xsl:attribute name="bookancestry">
                            <xsl:value-of select="$bookancestry"/>
                        </xsl:attribute>
                        <xsl:attribute name="seqnumber">
                            <xsl:value-of select="$seqNumber"/>
                        </xsl:attribute>
                        <title class="- topic/title ">
                            <xsl:if test="$seqNumber != ''">
                                <ph class=" topic/ph " outputclass="seqNumber"><xsl:value-of
                                        select="concat($seqNumber, ' ')"/></ph>
                            </xsl:if>                            
                            <xsl:choose>
                                <xsl:when
                                    test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]">
                                    <xsl:copy-of
                                        select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]/node()"
                                    />
                                </xsl:when>
                                <xsl:when test="@navtitle">
                                    <xsl:value-of select="@navtitle"/>
                                </xsl:when>
                            </xsl:choose>
                        </title>
                        <!--body class=" topic/body "/-->
                        <xsl:apply-templates mode="build-tree">
                            <xsl:with-param name="incomingDivNumber" select="$currentDivNumber"/>
                            <xsl:with-param name="seqNumber" select="$seqNumber"/>
                        </xsl:apply-templates>
                    </topic>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="build-tree">
                    <xsl:with-param name="incomingDivNumber" select="$currentDivNumber"/>
                    <xsl:with-param name="seqNumber" select="$seqNumber"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ************************************* -->
  <!-- Tagsmiths: All templates within this section are unchanged.
       They were copied for template precedence reasons. 31aug17 -->
  
  
  <xsl:template match="*[@print = 'no']" priority="5" mode="build-tree"/>
  
  <xsl:template
    match="
    *[contains(@class, ' bookmap/backmatter ')] |
    *[contains(@class, ' bookmap/booklists ')] |
    *[contains(@class, ' bookmap/frontmatter ')]"
    priority="2" mode="build-tree">
    <xsl:apply-templates mode="build-tree"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' bookmap/toc ')][not(@href)]" priority="2"
    mode="build-tree">
    <ot-placeholder:toc id="{generate-id()}">
      <xsl:apply-templates mode="build-tree"/>
    </ot-placeholder:toc>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' bookmap/indexlist ')][not(@href)]" priority="2"
    mode="build-tree">
    <ot-placeholder:indexlist id="{generate-id()}">
      <xsl:apply-templates mode="build-tree"/>
    </ot-placeholder:indexlist>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' bookmap/glossarylist ')][not(@href)]" priority="2"
    mode="build-tree">
    <ot-placeholder:glossarylist id="{generate-id()}">
      <xsl:apply-templates mode="build-tree"/>
    </ot-placeholder:glossarylist>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' bookmap/tablelist ')][not(@href)]" priority="2"
    mode="build-tree">
    <ot-placeholder:tablelist id="{generate-id()}">
      <xsl:apply-templates mode="build-tree"/>
    </ot-placeholder:tablelist>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' bookmap/figurelist ')][not(@href)]" priority="2"
    mode="build-tree">
    <ot-placeholder:figurelist id="{generate-id()}">
      <xsl:apply-templates mode="build-tree"/>
    </ot-placeholder:figurelist>
  </xsl:template>
  <!-- ************************************* -->

  <xsl:template match="*[contains(@class, ' topic/topic ')]">
        <xsl:param name="parentId"/>
        <!-- Tagsmiths: Added parameters bookancestry and seqNumber.-->
        <xsl:param name="bookancestry"/>
        <xsl:param name="seqNumber"/>
        <xsl:param name="incomingDivNumber"/>
        <xsl:variable name="idcount">
            <!--for-each is used to change context.  There's only one entry with a key of $parentId-->
            <xsl:for-each select="key('topicref', $parentId)">
                <xsl:value-of
                    select="count(preceding::*[@href = current()/@href][not(ancestor::*[contains(@class, ' map/reltable ')])]) + count(ancestor::*[@href = current()/@href])"
                />
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*[name() != 'id']"/>
            <xsl:variable name="new_id">
                <xsl:choose>
                    <xsl:when test="number($idcount) &gt; 0">
                        <xsl:value-of select="concat(@id, '_ssol', $idcount)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="id">
                <xsl:value-of select="$new_id"/>
            </xsl:attribute>
            <xsl:attribute name="bookancestry">
                <xsl:value-of select="$bookancestry"/>
            </xsl:attribute>
            <xsl:attribute name="seqnumber">
                <xsl:value-of select="$seqNumber"/>
            </xsl:attribute>
            <xsl:apply-templates>
                <xsl:with-param name="newid" select="$new_id"/>
                <xsl:with-param name="seqNumber" select="$seqNumber"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="key('topicref', $parentId)/*" mode="build-tree">
                <xsl:with-param name="incomingDivNumber" select="$incomingDivNumber"/>
                <xsl:with-param name="seqNumber" select="$seqNumber"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]">
        <xsl:param name="seqNumber"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="$seqNumber != ''">
                <ph class=" topic/ph " outputclass="seqNumber"><xsl:value-of
                    select="concat($seqNumber, '&#x2002;')"/></ph>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- Linkless topicref or topichead -->
    <xsl:template match="*[contains(@class, ' map/topicref ')][not(@href)]" priority="5">
        <xsl:param name="newid"/>
        <!-- Tagsmiths: Added parameters bookancestry and seqNumber.-->
        <xsl:param name="bookancestry"/>
        <xsl:param name="seqNumber"/>
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*">
                <xsl:with-param name="newid" select="$newid"/>
            </xsl:apply-templates>
            <xsl:attribute name="bookancestry">
                <xsl:value-of select="$bookancestry"/>
            </xsl:attribute>
            <xsl:attribute name="seqnumber">
                <xsl:value-of select="$seqNumber"/>
            </xsl:attribute>
            <xsl:apply-templates select="* | text() | processing-instruction()">
                <xsl:with-param name="newid" select="$newid"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!-- Tagsmiths: Counting for chapters, parts, and appendixes. -->
    <xsl:template name="getNumber">
        <xsl:param name="divNumber"/>
        <xsl:choose>
            <!-- Element is chapter with an active href -->
            <xsl:when
                test="
                    .[contains(@class, ' bookmap/chapter ')] and
                    (
                    not(normalize-space(@href) = '') or
                    @navtitle or
                    *[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]
                    )">
                <xsl:number value="count(preceding::*[contains(@class, ' bookmap/chapter ')]) + 1"/>
            </xsl:when>
            <!-- Parent is chapter with null href and no navtitle -->
            <xsl:when
                test="
                    parent::*[contains(@class, ' bookmap/chapter ')] and
                    parent::*[normalize-space(@href) = ''] and
                    not(
                    parent::*/@navtitle or
                    parent::*/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]
                    )">
                <xsl:number value="count(preceding::*[contains(@class, ' bookmap/chapter ')]) + 1"/>
            </xsl:when>
            <!-- Element is appendix with an active href -->
            <xsl:when
                test="
                    .[contains(@class, ' bookmap/appendix ')] and
                    (
                    not(normalize-space(@href) = '') or
                    @navtitle or
                    *[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]
                    )">
                <xsl:number value="count(preceding::*[contains(@class, ' bookmap/appendix ')]) + 1"
                    format="A"/>
            </xsl:when>
            <!-- Parent is appendix with null href and no navtitle-->
            <xsl:when
                test="
                    parent::*[contains(@class, ' bookmap/appendix ')] and
                    parent::*[normalize-space(@href) = ''] and
                    not(
                    parent::*/@navtitle or
                    parent::*/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]
                    )">
                <xsl:number value="count(preceding::*[contains(@class, ' bookmap/appendix ')]) + 1"
                    format="A"/>
            </xsl:when>
            <!-- Element is part with an active href -->
            <xsl:when
                test="
                    .[contains(@class, ' bookmap/part ')] and
                    (
                    not(normalize-space(@href) = '') or
                    @navtitle or
                    *[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]
                    )">
                <xsl:number value="count(preceding::*[contains(@class, ' bookmap/part ')]) + 1" format="I"/>
            </xsl:when>
            <!-- Parent is part with null href and no navtitle-->
            <xsl:when
                test="
                    parent::*[contains(@class, ' bookmap/part ')] and
                    parent::*[normalize-space(@href) = ''] and
                    not(
                    parent::*/@navtitle or
                    parent::*/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]
                    )">
                <xsl:number value="count(preceding::*[contains(@class, ' bookmap/part ')]) + 1" format="I"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="subNumber">
                  <xsl:number level="multiple" format="1.1" from="*[contains(@class, ' bookmap/chapter ') or contains(@class, ' bookmap/appendix ')]"
                        count="topicref[@format = 'dita' or empty(@format)] | topichead"/>
                </xsl:variable>
                <xsl:choose>
                    <!-- Don't return numbers when nested more than three levels (e.g., the chapter plus 3). 
                           The presence of two periods (e.g., 2.1.4) means that the level is too deep.-->
                    <xsl:when test="matches($subNumber, '\..*\.')"/>
                    <!-- Don't return numbers when there is no divNumber. -->
                    <xsl:when test="$divNumber = ''"/>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($divNumber, '.', $subNumber)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  
  <xsl:function name="ts:getOriginalElementName">
    <xsl:param name="classAttr"/>
    <xsl:sequence select="replace($classAttr, '.+/([^ ]+) *', '$1')"/>
  </xsl:function>

</xsl:stylesheet>
