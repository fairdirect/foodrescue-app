<?xml version='1.0'?>

<!-- Call as:
xmlpatterns xmlpatterns-ex03-foreach.xsl xmlpatterns-ex03-foreach.xml
-->

<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook"
>
    <xsl:output method="html" />

    <xsl:variable name="absolute-root" select="/"/>

    <xsl:template match="/db:book" >

        <xsl:for-each select="./db:topic" >
            <xsl:variable name="key" select="@type" />
            @type = <xsl:value-of select="@type" />
            $key = <xsl:value-of select="$key" />

            <xsl:variable name="key">'<xsl:value-of select="@type" />'</xsl:variable>
            @type = <xsl:value-of select="@type" />
            $key = <xsl:value-of select="$key" />

            <xsl:variable name="key" select="'pantry_storage'" />
            @type = <xsl:value-of select="@type" />
            $key = <xsl:value-of select="$key" />

            test1 = <xsl:value-of select="not(preceding-sibling::db:topic[@type = 'pantry_storage'])" />
            test2 = <xsl:value-of select="not(preceding-sibling::db:topic[@type = $key])" />

            <!--
            <xsl:if test="preceding-sibling::db:topic[@type] = 'pantry_storage'" >
                <h1>GROUP HEADER: <xsl:value-of select="@type" /></h1>
                <xsl:for-each select="../db:topic[@type=$key]" >
                    <xsl:apply-templates />
                </xsl:for-each>
            </xsl:if>
            -->
            -------------

        </xsl:for-each>

        ============================
        <!-- THIS WORKS (but only for one section, so would need a long sequence) -->
        <xsl:if test="./db:topic[@type = 'pantry_storage']" >
            <h1>GROUP HEADER</h1>

            <xsl:for-each select="./db:topic[@type = 'pantry_storage']" >
                -------------
                <xsl:apply-templates/>
            </xsl:for-each>
        </xsl:if>

        ============================
        <xsl:variable name="typename" select="./db:topic[1][@type]" />
        $typename = <xsl:value-of select="$typename" />

        ----

        <xsl:if test="./db:topic[@type = 'pantry_storage']" >
            <h1>GROUP HEADER</h1>

            <xsl:for-each select="./db:topic[@type = 'pantry_storage']" >
                -------------
                <xsl:apply-templates/>
            </xsl:for-each>
        </xsl:if>

        ============================

        <!-- This test leads to a segfault -->
        <xsl:variable name="book" select="." />

        <xsl:for-each
            select="
                'pantry_storage',
                'There',
                'World'
            "
        >
            <!-- Enable this to get the segfault. It's due to adding "/db:topic".
            <xsl:if test="$book/db:topic" >
                <h1>GROUP HEADER</h1>
            </xsl:if>
            -->
        </xsl:for-each>

        ===========================
        <xsl:for-each
            select="
                'pantry_storage'
            "
        >

        <xsl:call-template name="section">
            <xsl:with-param name="type" select="'pantry_storage'"/>
        </xsl:call-template>

        </xsl:for-each>

    </xsl:template>


    <xsl:template name="section">
        <xsl:param name="type"/>

        <xsl:if test="./db:topic[@type = $type]" >
            <h1>GROUP HEADER</h1>

            <xsl:for-each select="./db:topic[@type = $type]" >
                -------------
                <xsl:apply-templates/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <!--
    <xsl:for-each-group select="./db:topic" group-by="@type">
        <xsl:for-each select="current-group()">
            <h1>GROUP HEADER: <xsl:value-of select="@type"/></h1>
            <xsl:apply-templates/>
        </xsl:for-each>
    </xsl:for-each-group>
    -->

    <!--
    <xsl:for-each select="./db:topic">
        <xsl:variable name="key" select="substring(@type, string-length(@type))" />
        <xsl:if test="not(preceding-sibling::[substring(@type, string-length(@type))=$key])">
            <h1>GROUP HEADER: <xsl:value-of select="@type"/></h1>
            <xsl:for-each select="../db:topic[@type=$key]">
                <xsl:apply-templates/>
            </xsl:for-each>
        </xsl:if>
    </xsl:for-each>
    -->

</xsl:stylesheet>
