<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

  <xsl:output method="xml" indent="yes"/>

  <!-- TODO Идентификатор поставщика (GUID) -->
  <xsl:variable name="supplier_GUID">CCE48F89-236B-4392-8ECD-98B1C3547EDA</xsl:variable>
  <!-- TODO Идентификатор каталога поставщика (GUID) -->
  <xsl:variable name="catalog_GUID">73919D73-5B3D-4A11-AF3D-CCC08551C6D1</xsl:variable>

  <xsl:template match="КоммерческаяИнформация">
    <КоммерческаяИнформация>
      <xsl:apply-templates select="Документ" mode="Каталог"/>
      <xsl:apply-templates select="Документ" mode="Документ" />
      <xsl:apply-templates select="Документ" mode="Контрагент"/>
    </КоммерческаяИнформация>
  </xsl:template>

  <xsl:template match="Документ" mode="Каталог">
    <Каталог>
      <xsl:attribute name="Идентификатор"><xsl:value-of select="$catalog_GUID"/></xsl:attribute>
      <xsl:attribute name="Наименование">Каталог товаров</xsl:attribute>
      <xsl:attribute name="Владелец"><xsl:value-of select="$supplier_GUID"/></xsl:attribute>
      <xsl:attribute name="Единица">шт</xsl:attribute>
      <xsl:apply-templates select="Товары/Товар" mode="Каталог"/>
    </Каталог>
  </xsl:template>

  <xsl:template match="Товары/Товар" mode="Каталог">
    <Товар>
      <xsl:attribute name="ИдентификаторВКаталоге">
        <xsl:choose>
          <xsl:when test='substring(Ид,1,1)="*"'>
            <xsl:value-of select='substring(Ид,2)'/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="Ид"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="Наименование">
        <xsl:value-of select="Наименование"/>
      </xsl:attribute>
      <xsl:attribute name="Единица">
        <xsl:value-of select="Единица"/>
      </xsl:attribute>
    </Товар>
  </xsl:template>

  <xsl:template match="Документ" mode="Контрагент">
    <Контрагент>
      <xsl:attribute name="Идентификатор"><xsl:value-of select="$supplier_GUID"/></xsl:attribute>
      <xsl:attribute name="Наименование">Поставщик</xsl:attribute>
    </Контрагент>
  </xsl:template>

  <xsl:template match="Документ" mode="Документ">
    <Документ>
      <xsl:attribute name="Дата">
        <xsl:value-of select="Дата"/>
      </xsl:attribute>
      <xsl:attribute name="Номер">
        <xsl:value-of select="Номер"/>
      </xsl:attribute>
      <xsl:attribute name="Время">
        <xsl:value-of select="Время"/>
      </xsl:attribute>
      <xsl:attribute name="ХозОперация">
        <xsl:choose>
          <xsl:when test="ХозОперация='Заказ товара'">Order</xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">Error</xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="Валюта">руб.</xsl:attribute>
      <xsl:attribute name="Курс">1</xsl:attribute>
      <xsl:attribute name="Кратность">1</xsl:attribute>
      <xsl:attribute name="Комментарий">Контрагент:<xsl:value-of select="Контрагенты/Контрагент[1]/Наименование"/>, ИНН:<xsl:value-of select="Контрагенты/Контрагент[1]/ИНН"/>, Коммент.контр:<xsl:value-of select="Комментарий"/></xsl:attribute>
      <xsl:apply-templates select="Контрагенты/Контрагент" />
      <xsl:apply-templates select="Товары/Товар" mode="Документ"/>
    </Документ>
  </xsl:template>

  <xsl:template match="Контрагент">
    <xsl:if test="Роль='Продавец'">
      <ПредприятиеВДокументе>
        <xsl:attribute name="Контрагент"><xsl:value-of select="$supplier_GUID"/></xsl:attribute>
        <xsl:attribute name="Роль">Saler</xsl:attribute>
      </ПредприятиеВДокументе>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Товар" mode="Документ">
    <ТоварнаяПозиция>
      <xsl:attribute name="Каталог"><xsl:value-of select="$catalog_GUID"/></xsl:attribute>
      <xsl:attribute name="Товар">
        <xsl:choose>
          <xsl:when test="contains(Ид,'*')">
            <xsl:value-of select="substring-after(Ид,'*')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="Ид"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="Единица">
        <xsl:value-of select="Единица"/>
      </xsl:attribute>
      <xsl:attribute name="Количество">
        <xsl:value-of select="Количество"/>
      </xsl:attribute>
    </ТоварнаяПозиция>
  </xsl:template>

</xsl:stylesheet>