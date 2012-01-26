<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" mc:Ignorable="w14 wp14">
    <w:body>
    <w:p w:rsidR="008E3083" w:rsidRPr="008E3083" w:rsidRDefault="008E3083"><w:pPr><w:rPr><w:b/><w:u w:val="single"/></w:rPr></w:pPr><w:r w:rsidRPr="008E3083"><w:rPr><w:b/><w:u w:val="single"/></w:rPr><w:t>Movies</w:t></w:r></w:p>

    <xsl:for-each select="Movies/Genre">
      <w:p w:rsidR="008E3083" w:rsidRDefault="008E3083"><w:r><w:t>
        <xsl:value-of select="@name" />
      </w:t></w:r></w:p>
      <xsl:for-each select="Movie">
        <w:p w:rsidR="008E3083" w:rsidRDefault="008E3083" w:rsidP="008E3083">
          <w:pPr><w:pStyle w:val="ListParagraph"/><w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr></w:pPr>
          <w:r><w:t><xsl:value-of select="Name" /></w:t></w:r><w:proofErr w:type="spellStart"/><w:r><w:t><xsl:value-of select="Released"/></w:t></w:r><w:proofErr w:type="spellEnd"/><w:r><w:t>)</w:t></w:r>
          <w:bookmarkStart w:id="0" w:name="_GoBack"/><w:bookmarkEnd w:id="0"/>
        </w:p>
      </xsl:for-each>
    </xsl:for-each>
    <w:sectPr w:rsidR="008E3083"><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1417" w:right="1417" w:bottom="1134" w:left="1417" w:header="708" w:footer="708" w:gutter="0"/><w:cols w:space="708"/><w:docGrid w:linePitch="360"/></w:sectPr>
    </w:body>
    </w:document>
  </xsl:template>
</xsl:stylesheet>
