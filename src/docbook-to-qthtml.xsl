<?xml version='1.0'?>

<!--
!!!! Stylesheet to convert DocBook XML to Qt's Text.RichText format, a HTML 4 subset.
!!!!
!!!! See for the documentation of Qt's Text.RichText format: https://doc.qt.io/qt-5/richtext-html-subset.html
!!!! In addition, some undocumented features are available:
!!!! * custom tags, see https://stackoverflow.com/q/62684658
!!!! * style element in the header, with CSS styling for tags and classes
!!!!
!!!! Remarks about the quirks and limitations of Qt's Text.RichText rendering:
!!!! * CSS "font-weight" has limited visually distinct settings, depending on the available fonts:
!!!!   * Ubuntu Linux 19:10: "light" (100-200), "normal" (300-500), bold (600-900)
!!!!   * Android 6: "light" (100-300), "normal" (400), demibold (500), bold (600), extra bold (700-900)
!!!! * CSS "margin" creates an empty space when used with block-level elements like "h1" but creates a
!!!!   space filled with the background color when used on a table; it has no effect on table cells
!!!! * CSS "padding" configures the empty space around table cells, not the CSS padding in any block
!!!!   level element like "h1"; it can only be used on table cells
!!!! * "width" has to be an attribute for the "table" tag, it cannot be used as a CSS property
!!!! * HTML entities like &nbsp; cannot be used (only after defining them somehow, perhaps)
!!!! * Block elements containing nothing or only whitespace are not rendered (also not their margin etc.).
!!!!   To create a spacer element, you can set color:transparent.
!!!! * The height of a "p" element does not shrink below ist normal height, independent of what
!!!!   you set for the "font-size" and "line-height" CSS attributes. It seems that the font size
!!!!   can be increased, but not decreased below its default size.
!!!! * As a vertical spacer, <table style="margin-bottom: 4px"/> works best.
!!!! * By default, there is a vertical margin between "p" elements. It can be removed with margin:0px.
!!!! * There is no default vertical margin around "div" or "table" elements.
!!!! * The minimum vertical space taken up by any element is ~16 px (one height of normal text). That
!!!!   applies even for a simple, empty <br/> and cannot be fixed by CSS.
!!!! * An inline element (like img) after a block-level element (p, div) is added to the last line of the
!!!!   block-level element.
!!!! * A <hr> tag produces no visible output, and it is not clear how to fix that.
!!!! * For a <div> between two tables, "margin-top" works but "margin-bottom" has no effect. However for
!!!!   a <div> between two "div" or "p" elements, both variants work.
!!!! * It is possible to use images with src="qrc:/…".
!!!! * A pixel can be considered ~1/16 of the default line height, roughly indepenent of device screen density.
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook"
>
    <xsl:output method="html"/>

    <!-- A "book xmlns=" element is namespaced so cannot be matched without a namespace
    prefix. See: https://stackoverflow.com/a/46478501 -->
    <xsl:template match="/db:book">
        <html>
            <head>
                <!-- No title element here, as Qt 5.12 renders it visibly atop the document due to a bug. -->
                <style>
                    table.h1 { background-color: lightslategray; }
                    table.h1 td { padding: 8px; }
                    table.h1 h1 { color: whitesmoke; font-weight: normal; }

                    table.h2 { background-color: lightgray; }
                    table.h2 td { padding: 4px; padding-left: 8px; }
                    table.h2 h2 { color: dimgray; font-weight: normal; }

                    em { font-style: italic; font-weight: bold; }

                    div.spacer-16 { color: transparent; margin-top: 0px; }
                    div.spacer-20 { color: transparent; margin-top: 4px; }
                    div.spacer-24 { color: transparent; margin-top: 8px; }
                    div.spacer-32 { color: transparent; margin-top: 16px; }
                    div.spacer-40 { color: transparent; margin-top: 24px; }
                    div.spacer-56 { color: transparent; margin-top: 40px; }
                    div.spacer-72 { color: transparent; margin-top: 56px; }
                </style>
            </head>
            <body><xsl:apply-templates/></body>
        </html>
    </xsl:template>

    <xsl:template match="db:info">
        <!-- TODO: Add appropriate output for the "info" element. -->
    </xsl:template>

    <xsl:template match="db:topic">
        <!-- TODO: Replace this placeholder of the section header. It must be rendered only once per
          section, not once per topic. -->
        <table class="h1" width="100%">
            <tr><td><h1>
                <xsl:choose>
                    <!-- Content section shortnames and titles are as defined in the official documentation,
                      see: https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA#z=ZYsoIiZKiCqqvdw_JZC4f7fV
                      When new sections are added there, they also have to be included here. -->
                    <!-- TODO: Render the proper i18n'ed versions of the section titles. -->
                    <xsl:when test="./@type = 'risks'">Risks and caveats</xsl:when>
                    <xsl:when test="./@type = 'assessment'">Edibility assessment</xsl:when>
                    <xsl:when test="./@type = 'symptoms'">Symptoms and causes</xsl:when>
                    <xsl:when test="./@type = 'post_spoilage'">Rescuing spoiled and damaged food</xsl:when>
                    <xsl:when test="./@type = 'donation_options'">Donation options</xsl:when>
                    <xsl:when test="./@type = 'edible_parts'">Edible parts</xsl:when>
                    <xsl:when test="./@type = 'residual_food'">Cleaning out packaging, and cleaning pots and plates</xsl:when>
                    <xsl:when test="./@type = 'unliked_food'">What to do when not liking a food item</xsl:when>
                    <xsl:when test="./@type = 'pantry_storage'">Pantry storage</xsl:when>
                    <xsl:when test="./@type = 'refrigerator_storage'">Refrigerator storage</xsl:when>
                    <xsl:when test="./@type = 'freezer_storage'">Freezer storage</xsl:when>
                    <xsl:when test="./@type = 'other_storage'">Other storage types</xsl:when>
                    <xsl:when test="./@type = 'commercial_storage'">Commercial storage and management</xsl:when>
                    <xsl:when test="./@type = 'preservation'">Preservation instructions</xsl:when>
                    <xsl:when test="./@type = 'preparation'">Preparation instructions</xsl:when>
                    <xsl:when test="./@type = 'reuse_and_recycling'">Reuse and recycling ideas</xsl:when>
                    <xsl:when test="./@type = 'production_waste'">Production waste</xsl:when>
                    <xsl:when test="./@type = 'packaging waste'">Packaging waste</xsl:when>

                    <xsl:otherwise><xsl:value-of select="./@type"/></xsl:otherwise>

                </xsl:choose>
            </h1></td></tr>
        </table>

        <div class="spacer-16">.</div>

        <table class="h2" width="100%">
            <tr><td><h2><xsl:value-of select="./db:info/db:title"/></h2></td></tr>
        </table>

        <xsl:apply-templates/>

        <div class="spacer-56">.</div>
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
