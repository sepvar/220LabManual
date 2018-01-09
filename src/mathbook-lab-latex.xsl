<?xml version='1.0'?> <!-- As XML file -->

<!-- For Thomas More College's Lab Manual -->

<!-- Identify as a stylesheet -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Import the usual LaTeX conversion templates            -->
<!-- Place this file in  mathbook/user  (mkdir if necessary)-->
<xsl:import href="../xsl/mathbook-latex.xsl" />

<xsl:param name="numbering.equations.level" select="'1'" />
<xsl:param name="latex.preamble.late">
    <xsl:text>\setlength{\evensidemargin}{0in}</xsl:text>
    <xsl:text>\setlength{\oddsidemargin}{-.15in}</xsl:text>
    <xsl:text>\setlength{\textwidth}{6.6in}</xsl:text>
    <xsl:text>\setlength{\marginparwidth}{.6in}</xsl:text>
    <xsl:text>\setlength{\marginparsep}{.15in}</xsl:text>
    
    <xsl:text>\setlength{\topmargin}{-0.75in}</xsl:text>
    <xsl:text>\setlength{\headheight}{0.1in}</xsl:text>
    <xsl:text>\setlength{\headsep}{0.25in}</xsl:text>
    <xsl:text>\setlength{\textheight}{9.2in}</xsl:text>
    <xsl:text>\setlength{\footskip}{0.5in}</xsl:text>
</xsl:param>

</xsl:stylesheet>
