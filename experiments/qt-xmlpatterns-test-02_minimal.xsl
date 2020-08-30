<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>

    <xsl:template match="document">
        <html>
            <head>
                <title><xsl:value-of select="./title"/></title>
            </head>
            <body><xsl:apply-templates/></body>
        </html>
    </xsl:template>

    <xsl:template match="title">
        <h1><xsl:apply-templates/></h1>
    </xsl:template>

    <xsl:template match="para">
        <p><xsl:apply-templates/></p>
    </xsl:template>

</xsl:stylesheet>

