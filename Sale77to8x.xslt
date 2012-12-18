<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
>
  <xsl:output method="xml" indent="yes"/>

  <xsl:variable name="client_inn">123</xsl:variable> <!-- ИНН и КПП покупателя -->
  <xsl:variable name="client_kpp">1234</xsl:variable>
  <xsl:variable name="firm_inn">12345</xsl:variable> <!-- ИНН и КПП поставщика -->
  <xsl:variable name="firm_kpp">123456</xsl:variable>
  <xsl:variable name="firm_vat">1</xsl:variable> <!-- НДС в сумме - 1 или сверху - 0 -->
  
  <xsl:variable name="firm_guid" select="/КоммерческаяИнформация/Каталог/@Владелец"/>
  <xsl:variable name="firm_catalog_guid" select="/КоммерческаяИнформация/Каталог/@Идентификатор"/>
  
  <xsl:variable name="salerID" select="/КоммерческаяИнформация/Документ/ПредприятиеВДокументе[@Роль='Saler']/@Контрагент"/>
  <xsl:variable name="saler" select="/КоммерческаяИнформация/Контрагент[@Идентификатор=$salerID]"/>
  <xsl:variable name="firm_shortname" select="$saler/@ОтображаемоеНаименование"/>
  <xsl:variable name="firm_fullname" select="$saler/@Наименование"/>
  <xsl:variable name="firm_address" select="$saler/@Адрес"/>

  <xsl:template match="КоммерческаяИнформация">
    <КоммерческаяИнформация ВерсияСхемы="2.04">
      <xsl:apply-templates select="Документ"/>
      <xsl:apply-templates select="Каталог" mode="Классификатор" />
      <xsl:apply-templates select="Каталог" mode="Каталог"/>
    </КоммерческаяИнформация>
  </xsl:template>

  <xsl:template match="Документ">
    <Документ>
      <Номер><xsl:value-of select="@Номер"/></Номер>
      <Дата><xsl:value-of select="@Дата"/></Дата>
      <xsl:choose>
        <xsl:when test="@ХозОперация='Sale'">
          <ХозОперация>Отпуск товара</ХозОперация>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">Ошибка!</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
      <Роль>Продавец</Роль>
      <Валюта>руб</Валюта>
      <Сумма><xsl:value-of select="@Сумма"/></Сумма>
      <СрокПлатежа><xsl:value-of select="@СрокПлатежа"/></СрокПлатежа>
      <Контрагенты>
        <xsl:apply-templates select="ПредприятиеВДокументе[@Роль='Saler']" mode="saler"/>
        <xsl:apply-templates select="ПредприятиеВДокументе[@Роль='Buyer']" mode="buyer"/>
      </Контрагенты>
      <Время><xsl:value-of select="@Время"/></Время>
      <Налоги>
        <Налог>
          <Наименование>НДС</Наименование>
          <УчтеноВСумме><xsl:value-of select="$firm_vat"/></УчтеноВСумме>
        </Налог>
      </Налоги>
      <Товары>
        <xsl:apply-templates select="ТоварнаяПозиция" mode="ТоварВДокументе"/>
      </Товары>
      <xsl:if test="(string-length(@Комментарий) > 0)">
      <Комментарий>
        <xsl:value-of select="@Комментарий"/>
      </Комментарий>
      </xsl:if>
    </Документ>
  </xsl:template>

  <xsl:template match="ПредприятиеВДокументе" mode="saler">
    <Контрагент>
      <xsl:variable name="orgId" select="@Контрагент"/>
      <Ид><xsl:value-of select="$orgId"/></Ид>
      <Наименование><xsl:value-of select="/КоммерческаяИнформация/Контрагент[@Идентификатор=$orgId]/@ОтображаемоеНаименование"/></Наименование>
      <ОфициальноеНаименование><xsl:value-of select="/КоммерческаяИнформация/Контрагент[@Идентификатор=$orgId]/@Наименование"/></ОфициальноеНаименование>
      <xsl:if test="string-length($firm_inn)>0">
        <ИНН><xsl:value-of select="$firm_inn"/></ИНН>
      </xsl:if>
      <xsl:if test="string-length($firm_kpp)>0">
        <КПП><xsl:value-of select="$firm_kpp"/></КПП>
      </xsl:if>
      <Роль>Продавец</Роль>
    </Контрагент>
  </xsl:template>

  <xsl:template match="ПредприятиеВДокументе" mode="buyer">
    <Контрагент>
      <xsl:variable name="orgId" select="@Контрагент"/>
      <Ид><xsl:value-of select="$orgId"/></Ид>
      <Наименование><xsl:value-of select="/КоммерческаяИнформация/Контрагент[@Идентификатор=$orgId]/@ОтображаемоеНаименование"/></Наименование>
      <ОфициальноеНаименование><xsl:value-of select="/КоммерческаяИнформация/Контрагент[@Идентификатор=$orgId]/@Наименование"/></ОфициальноеНаименование>
      <ЮридическийАдрес><Представление><xsl:value-of select="/КоммерческаяИнформация/Контрагент[@Идентификатор=$orgId]/@ЮридическийАдрес"/></Представление></ЮридическийАдрес>
      <xsl:if test="string-length($client_inn)>0">
        <ИНН><xsl:value-of select="$client_inn"/></ИНН>
      </xsl:if>
      <xsl:if test="string-length($client_kpp)>0">
        <КПП><xsl:value-of select="$client_kpp"/></КПП>
      </xsl:if>
      <Роль>Покупатель</Роль>
    </Контрагент>
  </xsl:template>

  <xsl:template match="ТоварнаяПозиция" mode="ТоварВДокументе">
    <xsl:variable name="prodId" select="@Товар"/>
    <xsl:variable name="product" select="/КоммерческаяИнформация/Каталог/Товар[@ИдентификаторВКаталоге=$prodId]"/>
    <xsl:variable name="parent" select="$product/@Родитель"/>
    <Товар>
      <Ид><xsl:value-of select="$prodId"/></Ид>
      <ИдКлассификатора>KL-<xsl:value-of select="$firm_catalog_guid"/></ИдКлассификатора>
      <Наименование><xsl:value-of select="$product/@Наименование"/></Наименование>
      <БазоваяЕдиница><xsl:value-of select="@Единица"/></БазоваяЕдиница>
      <!-- Идентификатор папки в которой лежит товар -->
      <Группы><Ид><xsl:value-of select="/КоммерческаяИнформация/Каталог/Группа[@Идентификатор=$parent]/@ИдентификаторВКаталоге"/></Ид></Группы>
      <ЦенаЗаЕдиницу><xsl:value-of select="@Цена"/></ЦенаЗаЕдиницу>
      <Количество><xsl:value-of select="@Количество"/></Количество>
      <Сумма><xsl:value-of select="@Сумма"/></Сумма>
      <Единица><xsl:value-of select="@Единица"/></Единица>
      <Коэффициент>1</Коэффициент>
      <Налоги><Налог><Наименование>НДС</Наименование><УчтеноВСумме>true</УчтеноВСумме></Налог></Налоги>
      <СтавкиНалогов><СтавкаНалога><Наименование>НДС</Наименование><Ставка>18%</Ставка></СтавкаНалога></СтавкиНалогов>
      <ЗначенияРеквизитов>
        <ЗначениеРеквизита><Наименование>ВидНоменклатуры</Наименование><Значение>Товар</Значение></ЗначениеРеквизита>
        <ЗначениеРеквизита><Наименование>ТипНоменклатуры</Наименование><Значение>Товар</Значение></ЗначениеРеквизита>
      </ЗначенияРеквизитов>
    </Товар>
  </xsl:template>

  <xsl:template match="Товар" mode="ТоварВКаталоге">
    <xsl:variable name="prodId" select="@ИдентификаторВКаталоге"/>
    <xsl:variable name="parent" select="@Родитель"/>
    <Товар>
      <Ид><xsl:value-of select="$prodId"/></Ид>
      <ИдКлассификатора>KL-<xsl:value-of select="$firm_catalog_guid"/></ИдКлассификатора>
      <Наименование><xsl:value-of select="@Наименование"/></Наименование>
      <БазоваяЕдиница><xsl:value-of select="@Единица"/></БазоваяЕдиница>
      <Группы><Ид><xsl:value-of select="../Группа[@Идентификатор=$parent]/@ИдентификаторВКаталоге"/></Ид></Группы>
      <СтавкиНалогов><СтавкаНалога><Наименование>НДС</Наименование><Ставка>18%</Ставка></СтавкаНалога></СтавкиНалогов>
      <ЗначенияРеквизитов>
        <ЗначениеРеквизита><Наименование>ВидНоменклатуры</Наименование><Значение>Товар</Значение></ЗначениеРеквизита>
        <ЗначениеРеквизита><Наименование>ТипНоменклатуры</Наименование><Значение>Товар</Значение></ЗначениеРеквизита>
      </ЗначенияРеквизитов>
    </Товар>
  </xsl:template>

  <xsl:template match="Каталог" mode="Классификатор">
    <Классификатор>
      <Ид>KL-<xsl:value-of select="$firm_catalog_guid"/></Ид>
      <Наименование>Классификатор товаров</Наименование>
      <Владелец>
        <Ид><xsl:value-of select="$firm_guid"/></Ид>
        <Наименование><xsl:value-of select="$firm_shortname"/></Наименование>
        <ОфициальноеНаименование><xsl:value-of select="$firm_fullname"/></ОфициальноеНаименование>
        <ЮридическийАдрес><Представление><xsl:value-of select="$firm_address"/></Представление></ЮридическийАдрес>
        <ИНН><xsl:value-of select="$firm_inn"/></ИНН>
        <КПП><xsl:value-of select="$firm_kpp"/></КПП>
      </Владелец>
      <xsl:apply-templates select="." mode="Группы">
        <xsl:with-param name="parent">0</xsl:with-param>
      </xsl:apply-templates>
    </Классификатор>
  </xsl:template>

  <xsl:template match="Каталог" mode="Группы">
    <xsl:param name="parent"/>
    <Группы>
      <xsl:choose>
        <xsl:when test="$parent=0">
          <xsl:apply-templates select="Группа[not(@Родитель)]" mode="Классификатор"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="Группа[@Родитель=$parent]" mode="Классификатор"/>
        </xsl:otherwise>
      </xsl:choose>
    </Группы>
  </xsl:template>

  <xsl:template match="Группа" mode="Классификатор">
    <Группа>
      <xsl:variable name="cur_id" select="@Идентификатор"/>
      <Ид><xsl:value-of select="@ИдентификаторВКаталоге"/></Ид>
      <Наименование><xsl:value-of select="@Наименование"/></Наименование>
      <xsl:if test="count(../Группа[@Родитель=$cur_id])">
        <xsl:apply-templates mode="Группы" select="..">
          <xsl:with-param name="parent" select="$cur_id"/>
        </xsl:apply-templates>
      </xsl:if>
    </Группа>
  </xsl:template>

  <xsl:template match="Каталог" mode="Каталог">
    <Каталог>
      <Ид><xsl:value-of select="$firm_catalog_guid"/></Ид>
      <ИдКлассификатора>KL-<xsl:value-of select="$firm_catalog_guid"/></ИдКлассификатора>
      <Владелец>
        <Ид><xsl:value-of select="$firm_guid"/></Ид>
        <Наименование><xsl:value-of select="$firm_shortname"/></Наименование>
        <ОфициальноеНаименование><xsl:value-of select="$firm_fullname"/></ОфициальноеНаименование>
        <ЮридическийАдрес><Представление><xsl:value-of select="$firm_address"/></Представление></ЮридическийАдрес>
        <ИНН><xsl:value-of select="$firm_inn"/></ИНН>
        <КПП><xsl:value-of select="$firm_kpp"/></КПП>
      </Владелец>
      <Товары>
        <xsl:apply-templates select="Товар" mode="ТоварВКаталоге"/>
      </Товары>
    </Каталог>
  </xsl:template>
</xsl:stylesheet>