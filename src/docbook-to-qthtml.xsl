<?xml version='1.0'?>

<!--
    Stylesheet to convert DocBook XML to Qt's Text.RichText format, a HTML 4 subset.

    See for the documentation of Qt's Text.RichText format: https://doc.qt.io/qt-5/richtext-html-subset.html
    In addition, some undocumented features are available:

    * custom tags, see https://stackoverflow.com/q/62684658
    * style element in the header, with CSS styling for tags and classes

    Remarks about the quirks and limitations of Qt's HTML rendering using rendering. All of the below
    is about the Qt's HTML rendering using "textFormat: Text.RichText" (in QML); the other HTML
    rendering formats available provide much fewer options and different default CSS styling.

    * CSS "font-weight" has limited visually distinct settings, depending on the available fonts:
        * Ubuntu Linux 19.10: light (100-200), normal (300-500), bold (600-900)
        * Android 6: light (100-300), normal (400), demibold (500), bold (600), extra bold (700-900)
    * CSS "margin" creates an empty space when used with block-level elements like "h1" but creates a
      space filled with the background color when used on a table; it has no effect on table cells.
    * CSS "padding" configures the empty space around table cells, not the CSS padding in any block
      level element like "h1"; it can only be used on table cells.
    * "width" has to be an attribute for the "table" tag, it cannot be used as a CSS property.
    * HTML entities like `&nbsp;` cannot be used (only after defining them somehow, perhaps).
    * Block elements containing nothing or only whitespace are not rendered (also not their margin etc.).
      To create a spacer element, you can set color:transparent.
    * The height of a "p" element does not shrink below its normal height, independent of what
      you set for the "font-size" and "line-height" CSS attributes. It seems that the font size
      can be increased, but not decreased below its default size. To be able to use empty "p" elements
      as spacers of configurable height, you could try starting with a very small default font size
      for everything.
    * As a vertical spacer, `<table style="margin-bottom: 4px"/>` works best.
    * By default, there is a vertical margin between "p" elements. It can be removed with margin:0px.
    * There is no default vertical margin around "div" or "table" elements.
    * The minimum vertical space taken up by any element is approx. 16 px (one height of normal text). That
      applies even for a simple, empty `br` element and cannot be fixed by CSS.
    * An inline element (like "img") after a block-level element ("p", "div") is added to the last line of the
      block-level element.
    * A "hr" element tag produces no visible output, and it is not clear how to fix that.
    * For a "div" element between two tables, "margin-top" works but "margin-bottom" has no effect. However for
      a "div" element between two "div" or "p" elements, both variants work.
    * It is possible to use images with `src="qrc:/…"`.
    * A pixel can be considered approx. 1/16 of the default line height, roughly indepenent of device screen density.

    Remarks about the quirks and limitations of Qt's XSLT implementation:

    * TODO
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
            <body>

                <!-- Render the sections in the desired order. -->
                <!-- Sadly we cannot replace this with a xsl:for-each loop over strings because Qt's
                    variable binding in loops is broken, preventing access to anything outside the
                    loop context (which is just the strings in this case). -->
                <!-- Content section shortnames and header texts are as defined in the official documentation,
                    see: https://dynalist.io/d/To5BNup9nYdPq7QQ3KlYa-mA#z=ZYsoIiZKiCqqvdw_JZC4f7fV
                    When new sections are added there, they also have to be included here. -->
                <!-- TODO: Render the proper i18n'ed versions of the section titles. -->

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Risks and caveats</xsl:with-param> -->
                    <xsl:with-param name="header">Risiken und Vorsichtsmaßnahmen</xsl:with-param>
                    <xsl:with-param name="topictype">risks</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Edibility assessment</xsl:with-param> -->
                    <xsl:with-param name="header">Essbarkeit</xsl:with-param>
                    <xsl:with-param name="topictype">assessment</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Symptoms and causes</xsl:with-param> -->
                    <xsl:with-param name="header">Symptome und Ursachen</xsl:with-param>
                    <xsl:with-param name="topictype">symptoms</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Pantry storage</xsl:with-param> -->
                    <xsl:with-param name="header">Lagerung in der Vorratskammer</xsl:with-param>
                    <xsl:with-param name="topictype">pantry_storage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Refrigerator storage</xsl:with-param> -->
                    <xsl:with-param name="header">Lagerung im Kühlschrank</xsl:with-param>
                    <xsl:with-param name="topictype">refrigerator_storage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Freezer storage</xsl:with-param> -->
                    <xsl:with-param name="header">Lagerung im Gefrierschrank</xsl:with-param>
                    <xsl:with-param name="topictype">freezer_storage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Other storage types</xsl:with-param> -->
                    <xsl:with-param name="header">Andere Arten der Lagerung</xsl:with-param>
                    <xsl:with-param name="topictype">other_storage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Commercial storage and management</xsl:with-param> -->
                    <xsl:with-param name="header">Kommerzielle Lagerung und Handhabung</xsl:with-param>
                    <xsl:with-param name="topictype">commercial_storage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Donation options</xsl:with-param> -->
                    <xsl:with-param name="header">Spendenmöglichkeiten</xsl:with-param>
                    <xsl:with-param name="topictype">donation_options</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Rescuing spoiled and damaged food</xsl:with-param> -->
                    <xsl:with-param name="header">Maßnahmen bei Verderb und Beschädigung</xsl:with-param>
                    <xsl:with-param name="topictype">post_spoilage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Edible parts</xsl:with-param> -->
                    <xsl:with-param name="header">Essbare Bestandteile</xsl:with-param>
                    <xsl:with-param name="topictype">edible_parts</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Preservation instructions</xsl:with-param> -->
                    <xsl:with-param name="header">Konservierung</xsl:with-param>
                    <xsl:with-param name="topictype">preservation</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Preparation instructions</xsl:with-param> -->
                    <xsl:with-param name="header">Zubereitung</xsl:with-param>
                    <xsl:with-param name="topictype">preparation</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">When you don't like this food</xsl:with-param> -->
                    <xsl:with-param name="header">Wenn es nicht schmeckt</xsl:with-param>
                    <xsl:with-param name="topictype">unliked_food</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Cleaning out residual food</xsl:with-param> -->
                    <xsl:with-param name="header">Restmengen nutzen</xsl:with-param>
                    <xsl:with-param name="topictype">residual_food</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Reuse and recycling ideas</xsl:with-param> -->
                    <xsl:with-param name="header">Wiederverwendung und Recycling</xsl:with-param>
                    <xsl:with-param name="topictype">reuse_and_recycling</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Production waste</xsl:with-param> -->
                    <xsl:with-param name="header">Produktionsabfälle</xsl:with-param>
                    <xsl:with-param name="topictype">production_waste</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <!-- <xsl:with-param name="header">Packaging waste</xsl:with-param> -->
                    <xsl:with-param name="header">Verpackungsabfälle</xsl:with-param>
                    <xsl:with-param name="topictype">packaging_waste</xsl:with-param>
                </xsl:call-template>

            </body>
        </html>
    </xsl:template>


    <!-- Render all topics within one content section, such as "pantry storage". -->
    <xsl:template name="section">
        <xsl:param name="header"/>
        <xsl:param name="topictype"/>

        <xsl:if test="./db:topic[@type = $topictype]" >

            <!-- Create a gap to the previous content. Automatically omitted at the start of the document. -->
            <div class="spacer-56">.</div>

            <!-- Render the section title. -->
            <table class="h1" width="100%">
                <tr><td><h1><xsl:value-of select="$header" /></h1></td></tr>
            </table>

            <!-- Render the topics within the section. -->
            <xsl:for-each select="./db:topic[@type = $topictype]" >
                <div class="spacer-16">.</div>

                <table class="h2" width="100%">
                    <tr><td><h2><xsl:value-of select="./db:info/db:title"/></h2></td></tr>
                </table>

                <xsl:apply-templates/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <xsl:template match="db:info">
        <!-- TODO: Add appropriate output for the "info" element. Example:
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
