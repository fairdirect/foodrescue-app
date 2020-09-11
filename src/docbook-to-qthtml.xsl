<?xml version='1.0'?>

<!--
    Stylesheet to convert DocBook XML to Qt's Text.RichText format, a HTML 4 subset.

    See for the documentation of Qt's Text.RichText format: https://doc.qt.io/qt-5/richtext-html-subset.html
    In addition, some undocumented features are available:

    * The "style" element can be used in the header, allowing CSS styling by elements and CSS class name.
    * There are some custom elements, see https://stackoverflow.com/q/62684658 .

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
      To create a spacer element, use an element with dummy content and set color:transparent.
    * The minimum vertical space taken up by any element is approx. 16 px (the default height of text). That
      applies even for a simple, empty `br` element and cannot be fixed by CSS.
    * The height of a "p" element does not shrink below its default height, independent of what
      you set for the "font-size" and "line-height" CSS attributes. It seems that the font size
      can be increased, but not decreased below its default size. To be able to use empty "p" elements
      as spacers of configurable height, you could try starting with a very small default font size
      for everything.
    * By default, there is a vertical margin between "p" elements. It can be removed with margin:0px.
    * There is no default vertical margin around "div" or "table" elements.
    * An inline element (like "img") after a block-level element ("p", "div") is added to the last line of the
      block-level element.
    * A "hr" element produces no visible output, and it is not clear how to fix that.
    * For a "div" element between two tables, "margin-top" works but "margin-bottom" has no effect. However for
      a "div" element between "div" or "p" elements, both variants work.
    * It is possible to use images with `src="qrc:/…"`.
    * A pixel can be considered approx. 1/16 of the default line height, roughly indepenent of device screen density.
    * The CSS property "border" has no effect, for example "border: 10px solid rgb(200, 0, 0);". Splitting this into
      the individual properties border-width, border-style and border-color works, however.
    * When applying a border to a table, it is also applied to all table cells, except when also adding the CSS property
      "-qt-table-type: frame;" to the table. If not doing this, there would be two visible borders around a single-cell
      table, making it impossible to use the table for text frames. It is not possible to remove such a duplicate border
      by other means.
    * The CSS property "border-style" has no effect. A border is always rendered solid.
    * The heading default margins are approximately h1 {margin-top:20px} and h2 {margin-top:15px}.
    * The CSS uses the wrong "Internet explorer style" box model, where margin is counted from the inner border position
      instead of from the outer border position. This is true at least for tables and at least when using
      "-qt-table-type: frame".
    * When using "-qt-table-type: frame;", paddings and margins have no effect whatsoever on the gap between table content
      and table border. Except that "margin:" set on for example a h1 table content element will create a left margin, but
      no vertical margins.
    * It is somehow possible to only show parts of a table's borders (such as only the bottom), but it is not clear anymore
      how that was achieved once.
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:xl="http://www.w3.org/1999/xlink"
>
    <xsl:output method="html"/>

    <!-- A "book xmlns=" element is namespaced so cannot be matched without a namespace
        prefix. See: https://stackoverflow.com/a/46478501 -->
    <xsl:template match="/db:book">
        <html>
            <head>
                <!-- No title element here, as Qt 5.12 renders it visibly atop the document due to a bug. -->

                <style>
                    table.h1 {
                        -qt-table-type: frame;
                        border-width: 2px;
                        border-color: rgb(210, 210, 210);
                    }
                    table.h1 td { }
                    table.h1 h1 {
                        margin-left: 10px;
                        color: rgb(60, 60, 60);
                        font-size: 32pt;
                        font-weight: bold;
                    }

                    h2 {
                        margin-top: 10px;
                        color: rgb(60, 60, 60);
                        font-size: 26pt;
                    }

                    h3 {
                        margin-top: 15px;
                        color: rgb(120, 120, 120);
                        font-size: 16pt;
                    }

                    em { font-style: normal; font-weight: bold; color: rgb(70, 70, 70); }
                    a { text-decoration: none; }

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
                    <xsl:with-param name="header"><xsl:value-of select="$assessment-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">assessment</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$pantry-storage-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">pantry_storage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$refrigerator-storage-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">refrigerator_storage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$freezer-storage-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">freezer_storage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$other-storage-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">other_storage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$commercial-storage-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">commercial_storage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$risks-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">risks</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$symptoms-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">symptoms</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$donation-options-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">donation_options</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$post-spoilage-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">post_spoilage</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$edible-parts-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">edible_parts</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$preservation-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">preservation</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$preparation-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">preparation</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$utilization-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">utilization</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$unliked-food-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">unliked_food</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$residual-food-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">residual_food</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$reuse-and-recycling-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">reuse_and_recycling</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$production-waste-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">production_waste</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="section">
                    <xsl:with-param name="header"><xsl:value-of select="$packaging-waste-title"/></xsl:with-param>
                    <xsl:with-param name="topictype">packaging_waste</xsl:with-param>
                </xsl:call-template>

            </body>
        </html>
    </xsl:template>


    <!-- Render all topics within one topic type section, such as "pantry_storage". -->
    <!-- TODO: Rename this template to "topic" because it matches a topic. Otherwise it's confusing
      because DocBook also has an element "section". -->
    <xsl:template name="section">
        <xsl:param name="header"/>
        <xsl:param name="topictype"/>

        <xsl:if test="./db:topic[@type = $topictype]" >

            <!-- Create a gap to the previous content.
                This is automatically rendered with zero height at the start of the document due to
                a Qt bug, but in this case this is an advantage over table { margin-top: 56px; }.
            -->
            <div class="spacer-40">.</div>

            <!-- Render the section title. -->
            <table class="h1" width="100%">
                <tr><td><h1><xsl:value-of select="$header" /></h1></td></tr>
            </table>

            <!-- Render the topics within the section. -->
            <xsl:for-each select="./db:topic[@type = $topictype]" >
                <h2><xsl:value-of select="./db:info/db:title"/></h2>
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


    <!-- TODO: Also support nested sections, then using h4-h6 elements. However, these are not yet used in
      the database. -->
    <xsl:template match="db:section">
        <!-- Not wrapping the <h3> into a table as for the superordinate headings, as this messes up the
        vertical spacing. It would have to be configured different for the first and subsequent h3 headings.
        And since h3 headings are very rare anyway and the default formatting is ok, it's not worth the effort. -->
        <h3><xsl:value-of select="./db:title"/></h3>

        <xsl:apply-templates select="* except ./db:title"/>
    </xsl:template>


    <xsl:template match="db:orderedlist">
        <ol><xsl:apply-templates/></ol>
    </xsl:template>


    <xsl:template match="db:itemizedlist">
        <ul><xsl:apply-templates/></ul>
    </xsl:template>


    <xsl:template match="db:listitem">
        <li><xsl:apply-templates /></li>
    </xsl:template>


    <!-- Ignore ignore <simpara> if inside <listitem>.
      We can simplify the output this way because <li> in HTML can contain text elements. <listitem>
      in DocBook can not; see the list of child elements at https://tdg.docbook.org/tdg/5.1/listitem.html .
      Order relative to <xsl:template match="db:simpara"> is not important as the most specific template
      matches.
    -->
    <xsl:template match="db:listitem/db:simpara">
        <xsl:apply-templates />
    </xsl:template>


    <xsl:template match="db:simpara">
        <p><xsl:apply-templates/></p>
    </xsl:template>


    <xsl:template match="db:emphasis[@role='strong']">
        <strong><xsl:apply-templates/></strong>
    </xsl:template>


    <xsl:template match="db:emphasis[not(@role='strong')]">
        <em><xsl:apply-templates/></em>
    </xsl:template>


    <xsl:template match="db:link">
        <!-- The {…} syntax is a XSLT attribute value template, see:
          https://www.w3.org/TR/2017/REC-xslt-30-20170608/#attribute-value-templates -->
        <a href="{@xl:href}"><xsl:apply-templates/></a>
    </xsl:template>

</xsl:stylesheet>
