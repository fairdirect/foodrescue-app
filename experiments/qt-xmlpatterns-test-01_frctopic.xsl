<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook"
>
    <xsl:output method="html"/>

    <!-- A "book xmlns=" element is namespaced so cannot be matched without a namespace
    prefix. See: https://stackoverflow.com/a/46478501 -->
    <xsl:template match="/db:book">
        <html>
            <head>
                <title><xsl:value-of select="./db:topic/db:info/db:title"/></title>
            </head>
            <body><xsl:apply-templates/></body>
        </html>
    </xsl:template>

    <xsl:template match="db:info">
      <!-- TODO: Add appropriate output for the "info". -->
    </xsl:template>

    <xsl:template match="db:topic">
        <!-- TODO: Replace this placeholder of the section header. -->
        <h1><xsl:value-of select="./@type"/></h1>

        <h2><xsl:value-of select="./db:info/db:title"/></h2>

        <div><xsl:apply-templates/></div>
    </xsl:template>

    <xsl:template match="db:simpara">
        <p><xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="db:itemizedlist">
        <ul><xsl:apply-templates/></ul>
    </xsl:template>

    <xsl:template match="db:listitem">
        <li><xsl:apply-templates/></li>
    </xsl:template>

    <xsl:template match="db:emphasis">
        <em><xsl:apply-templates/></em>
    </xsl:template>
</xsl:stylesheet>


<!-- Content that still has to be transformed:
<info>
    <edition><date>2020-05-01</date></edition>

    <abstract>
        <simpara>It stays fresh for about a week.</simpara>
    </abstract>

    <subjectset scheme="off-categories-subset-frc">
        <subject>
            <subjectterm>meats</subjectterm>
        </subject>

        <subject>
            <subjectterm>hams</subjectterm>
        </subject>
    </subjectset>
</info>
-->
