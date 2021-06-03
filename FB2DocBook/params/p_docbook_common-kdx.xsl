<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.1">
    <xsl:import href="p_docbook_common-default.xsl"/>
    <xsl:output encoding="UTF-8" indent="no" method="xml"/>

<!-- ==================================================================== -->


    <!-- Оглавление -->

    <xsl:attribute-set name="toc.line.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">
            <xsl:value-of select="$title.fontset"/>
        </xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <!-- * абсолютный (xx-small | x-small | small | medium | large | x-large | xx-large) -->
        <!-- * относительный (larger | smaller) -->
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.6"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>

        <!-- Вес (жирность) шрифта (normal | bold) -->
        <xsl:attribute name="font-weight">bold</xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">normal</xsl:attribute>

        <!-- Выравнивание последней строки (когда нужно визуальное заполнение блока) -->
        <!-- (start | center | end | justify | left | right | inside | outside | relative) -->
        <xsl:attribute name="text-align-last">justify</xsl:attribute>

        <!-- Поля текстового блока (размер | inherit) -->
        <xsl:attribute name="margin-left">20pt</xsl:attribute>
        <xsl:attribute name="margin-right">30pt</xsl:attribute>

        <!-- Минимальная высота строки (normal | размер | число | проценты | {space} | inherit) -->
        <xsl:attribute name="line-height">150%</xsl:attribute>

        <!-- Расстановка переносов (false | true | inherit) -->
        <xsl:attribute name="hyphenate">true</xsl:attribute>

        <!-- Разрыв строк (wrap | no-wrap | inherit) -->
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>

        <!-- Отступ текста от конечного края (правый по умолчанию; размер | проценты | inherit) -->
        <xsl:attribute name="end-indent">
            <xsl:value-of select="concat($toc.indent.width, 'pt')"/>
        </xsl:attribute>

        <!-- Отступ только последней строки от начального края (левый по умолчанию; размер | проценты | inherit) -->
        <xsl:attribute name="last-line-end-indent">
            <xsl:value-of select="concat('-', $toc.indent.width, 'pt')"/>
        </xsl:attribute>

        <!-- Сворачивание последовательных пробелов в один (false | true | inherit) -->
        <xsl:attribute name="white-space-collapse">true</xsl:attribute>

    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Верхний колонтитул (отключён) -->
    <xsl:template name="header.content"/>


    <!-- Нижний колонтитул (отключён) -->
    <xsl:template name="footer.content"/>


<!-- ==================================================================== -->


    <!-- Настройка обложки книги -->

    <!-- Расскоментировать для отключения сепаратора перед обложкой. -->
    <!-- Не особо нужно, только если есть набор книг (set). -->
    <xsl:template name="book.titlepage.before.verso"/>


    <!-- Расскоментировать для отключения первой страницы обложки -->
    <!-- xsl:template name="book.titlepage.recto"/ -->


    <!-- Расскоментировать для отключения сепаратора после информации о книге (обложки) -->
    <xsl:template name="book.titlepage.separator"/>


<!-- ==================================================================== -->


    <!-- Настройка аннотаций -->

    <!-- Стандартный заголовок находится в \docbook-xsl\common\ru.xml (для русского языка): -->
    <!-- {l:gentext key="Abstract" text="Аннотация"/} -->

    <!-- Заголовок аннотаций -->
    <xsl:attribute-set name="abstract.title.properties">

        <!-- Цвет шрифта (цвет | inherit), белый для скрытия заголовка -->
        <xsl:attribute name="color">rgb(255, 255, 255)</xsl:attribute>

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">
            <xsl:value-of select="$title.fontset"/>
        </xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.5"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>

        <!-- Вес (жирность) шрифта (normal | bold) -->
        <xsl:attribute name="font-weight">bold</xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">italic</xsl:attribute>

        <!-- Выравнивание текста (start | center | end | justify | left | right | inside | outside) -->
        <xsl:attribute name="text-align">center</xsl:attribute>

        <!-- Расстановка переносов (false | true | inherit) -->
        <xsl:attribute name="hyphenate">false</xsl:attribute>

        <!-- Разрыв страниц: не отрывать объект от следующего (auto | always | целое | inherit) -->
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>

        <!-- Расстояния между параграфами (до и после) -->
        <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>

    </xsl:attribute-set>


    <!-- Текст аннотаций (отступы и поля наследуются от normal.para.spacing) -->
    <xsl:attribute-set name="abstract.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">
            <xsl:value-of select="$title.fontset"/>
        </xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.5"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>

        <!-- Вес (жирность) шрифта (normal | bold) -->
        <xsl:attribute name="font-weight">normal</xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">normal</xsl:attribute>

        <!-- Выравнивание текста (start | center | end | justify | left | right | inside | outside) -->
        <xsl:attribute name="text-align">justify</xsl:attribute>

        <!-- Расстановка переносов (false | true | inherit) -->
        <xsl:attribute name="hyphenate">true</xsl:attribute>

    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Компонентные части книги: part, chapter, section и др. -->

    <xsl:attribute-set name="component.title.properties">

        <!-- Центрировать названия компонентных частей книги (общее: выравнивание текста) -->
        <xsl:attribute name="text-align">center</xsl:attribute>

    </xsl:attribute-set>


    <!-- Секции: section -->
    <xsl:attribute-set name="section.title.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">
            <xsl:value-of select="$title.font.family"/>
        </xsl:attribute>

        <!-- Вес (жирность) шрифта (normal | bold) -->
        <xsl:attribute name="font-weight">bold</xsl:attribute>

        <!-- Центрировать названия секций (общее: выравнивание текста) -->
        <xsl:attribute name="text-align">center</xsl:attribute>

    </xsl:attribute-set>
    <!-- xsl:attribute-set name="section.properties"> </xsl:attribute-set -->


    <!-- Вложенные секции: первая -->
    <xsl:attribute-set name="section.title.level1.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.25"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
    </xsl:attribute-set>
    <!-- xsl:attribute-set name="section.level1.properties" use-attribute-sets="section.properties"> </xsl:attribute-set -->

    <!-- Вторая вложенная секция -->
    <xsl:attribute-set name="section.title.level2.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.20"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
    </xsl:attribute-set>
    <!-- xsl:attribute-set name="section.level2.properties" use-attribute-sets="section.properties"> </xsl:attribute-set -->

    <!-- Третья вложенная секция -->
    <xsl:attribute-set name="section.title.level3.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.15"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
    </xsl:attribute-set>
    <!-- xsl:attribute-set name="section.level3.properties" use-attribute-sets="section.properties"> </xsl:attribute-set -->

    <!-- Четвёрая вложенная секция -->
    <xsl:attribute-set name="section.title.level4.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.10"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
    </xsl:attribute-set>
    <!-- xsl:attribute-set name="section.level4.properties" use-attribute-sets="section.properties"> </xsl:attribute-set -->

    <!-- Пятая вложенная секция -->
    <xsl:attribute-set name="section.title.level5.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.05"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
    </xsl:attribute-set>
    <!-- xsl:attribute-set name="section.level5.properties" use-attribute-sets="section.properties"> </xsl:attribute-set -->


<!-- ==================================================================== -->


    <!-- Глобальные параметры документа -->

    <xsl:attribute-set name="root.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">
            <xsl:value-of select="$body.fontset"/>
        </xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.size"/>
        </xsl:attribute>

        <!-- Цвет шрифта (цвет | inherit) -->
        <!-- xsl:attribute name="color">rgb(0, 0, 0)</xsl:attribute -->

        <!-- Выравнивание текста (start | center | end | justify | left | right | inside | outside) -->
        <xsl:attribute name="text-align">
            <xsl:value-of select="$alignment"/>
        </xsl:attribute>

        <!-- Минимальная высота строки (normal | размер | число | проценты | {space} | inherit) -->
        <xsl:attribute name="line-height">
            <xsl:value-of select="$line-height"/>
        </xsl:attribute>

        <!-- Влияние верхних и нижних индексов на высоту строки -->
        <!-- Увеличивать: consider-shifts | не увеличивать: disregard-shifts -->
        <xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>

        <!-- Критерий выбора шрифта (auto | inherit | character-by-character) -->
        <xsl:attribute name="font-selection-strategy">character-by-character</xsl:attribute>

        <!-- Вдовы-сироты, они же висячие строки (целое | inherit) -->
        <xsl:attribute name="widows">
            <xsl:value-of select="1"/>
        </xsl:attribute>
        <xsl:attribute name="orphans">
            <xsl:value-of select="1"/>
        </xsl:attribute>

    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Общие параметры параграфа -->

    <!-- Отступ первой строки абзаца основного и прочего текста (переменные) -->
    <xsl:variable name="p.text-indent" select="'5%'"/>
    <xsl:variable name="other.text-indent" select="'0%'"/>

    <!-- Отступы для параграфа -->
    <xsl:attribute-set name="normal.para.spacing">

        <!-- Отступ текста от начального края (левый по умолчанию; размер | проценты | inherit) -->
        <xsl:attribute name="start-indent">
            <xsl:choose>
                <xsl:when test="@role = 'p'">0pt</xsl:when>
                <xsl:when test="@role = 'poem'">0pt</xsl:when>
                <xsl:otherwise>1.0em</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>

        <!-- Отступ текста от конечного края (правый по умолчанию; размер | проценты | inherit) -->
        <xsl:attribute name="end-indent">
            <xsl:choose>
                <xsl:when test="@role = 'p'">0pt</xsl:when>
                <xsl:when test="@role = 'poem'">0pt</xsl:when>
                <xsl:otherwise>0.75em</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>

        <!-- Отступ первой строки абзаца (размер | проценты | inherit) -->
        <xsl:attribute name="text-indent">
            <xsl:choose>
                <xsl:when test="@role = 'p'">
                    <xsl:value-of select="$p.text-indent"/>
                </xsl:when>
                <xsl:when test="@role = 'poem'">0pt</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$other.text-indent"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>

        <!-- Автоподстройка расстояния между параграфами для заполнения страниц по высоте -->
        <!-- достигается выставлением минимального, оптимального и максимального значений -->
        <!-- расстояния между параграфами (до и/или после, включая отрицательные) -->
        <!-- Возможны глюки в виде наползания основного текста на сноски -->
        <xsl:attribute name="space-before.minimum">0.0em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.0em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.0em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.0em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.0em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.0em</xsl:attribute>

    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Подстраничные сноски -->

    <!-- Стиль маркёров подстраничных сносок в тексте книги -->
    <xsl:attribute-set name="footnote.mark.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">
            <xsl:value-of select="$title.fontset"/>
        </xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">80%</xsl:attribute>

        <!-- Вес (жирность) шрифта (normal | bold) -->
        <xsl:attribute name="font-weight">bold</xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">normal</xsl:attribute>

    </xsl:attribute-set>


    <!-- Стиль линии, отделяющей подстраничные сноски от текста -->
    <xsl:attribute-set name="footnote.sep.leader.properties">

        <!-- Цвет линии (цвет | transparent | inherit) -->
        <xsl:attribute name="color">gray</xsl:attribute>

        <!-- Стиль линии (space | rule | dots | use-content | inherit) -->
        <xsl:attribute name="leader-pattern">rule</xsl:attribute>

        <!-- Длина линии (размер | проценты | inherit) -->
        <xsl:attribute name="leader-length">35mm</xsl:attribute>

    </xsl:attribute-set>


    <!-- Текст подстраничных сносок -->
    <xsl:attribute-set name="footnote.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">
            <xsl:value-of select="$title.fontset"/>
        </xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.825"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>

        <!-- Вес (жирность) шрифта (normal | bold) -->
        <xsl:attribute name="font-weight">normal</xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">normal</xsl:attribute>

        <!-- Отступ всего текста от начального края (левый по умолчанию; размер | проценты | inherit) -->
        <xsl:attribute name="start-indent">0pt</xsl:attribute>

        <!-- Отступ первой строки абзаца (размер | проценты | inherit) -->
        <xsl:attribute name="text-indent">
            <xsl:value-of select="$p.text-indent"/>
        </xsl:attribute>

        <!-- Выравнивание текста (start | center | end | justify | left | right | inside | outside) -->
        <xsl:attribute name="text-align">justify</xsl:attribute>

        <!-- Расстановка переносов (false | true | inherit) -->
        <xsl:attribute name="hyphenate">true</xsl:attribute>

        <!-- Разрыв строк (wrap | no-wrap | inherit) -->
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>

        <!-- Подобно wrap-option работает с символами перевода строки / linefeeds -->
        <!-- (ignore | preserve | treat-as-space | treat-as-zero-width-space | inherit) -->
        <xsl:attribute name="linefeed-treatment">treat-as-space</xsl:attribute>

        <!-- Минимальная высота строки для сносок (перекрывает глобальную) -->
        <!-- (normal | размер | число | проценты | {space} | inherit) -->
        <!-- xsl:attribute name="line-height">100%</xsl:attribute -->

    </xsl:attribute-set>


    <!-- Подстраничные сноски для таблиц (настройки аналогичны стандартным сноскам) -->
    <xsl:attribute-set name="table.footnote.properties">
        <xsl:attribute name="font-family">
            <xsl:value-of select="$title.fontset"/>
        </xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.5"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="text-align">justify</xsl:attribute>
        <xsl:attribute name="start-indent">0pt</xsl:attribute>
        <xsl:attribute name="text-indent">0pt</xsl:attribute>
        <xsl:attribute name="hyphenate">true</xsl:attribute>
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>
        <xsl:attribute name="linefeed-treatment">treat-as-space</xsl:attribute>
    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Надстрочник и подстрочник (стиль не связан с подстраничными сносками) -->

    <xsl:attribute-set name="superscript.properties">
        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.5"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="subscript.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.5"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Эпиграфы (в связке с fb2docbook\fb2docbook.xsl и подправленным docbook-xsl\fo\block.xsl) -->

    <xsl:attribute-set name="epigraph.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">inherit</xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">smaller</xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">italic</xsl:attribute>

        <!-- Выравнивание текста (start | center | end | justify | left | right | inside | outside) -->
        <xsl:attribute name="text-align">justify</xsl:attribute>

        <!-- Поля текстового блока (размер | inherit) -->
        <xsl:attribute name="margin-left">50pt</xsl:attribute>
        <xsl:attribute name="margin-right">0pt</xsl:attribute>

        <!-- Расстояния между параграфами (до и после) -->
        <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>

    </xsl:attribute-set>

<!-- ==================================================================== -->


    <!-- Цитаты и прочие выделенные блоки -->

    <xsl:attribute-set name="blockquote.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">inherit</xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">smaller</xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">italic</xsl:attribute>

        <!-- Выравнивание текста (start | center | end | justify | left | right | inside | outside) -->
        <xsl:attribute name="text-align">justify</xsl:attribute>

        <!-- Поля текстового блока (размер | inherit) -->
        <xsl:attribute name="margin-left">50pt</xsl:attribute>
        <xsl:attribute name="margin-right">0pt</xsl:attribute>

        <!-- Расстояния между параграфами (до и после) -->
        <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>

    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Стихотворения -->

    <xsl:attribute-set name="verbatim.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">inherit</xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">smaller</xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">italic</xsl:attribute>

        <!-- Выравнивание текста (start | center | end | justify | left | right | inside | outside) -->
        <xsl:attribute name="text-align">start</xsl:attribute>

        <!-- Поля текстового блока (размер | inherit) -->
        <xsl:attribute name="margin-left">50pt</xsl:attribute>

        <!-- Расстановка переносов (false | true | inherit) -->
        <xsl:attribute name="hyphenate">false</xsl:attribute>

        <!-- Разрыв строк (wrap | no-wrap | inherit) -->
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>

        <!-- Сворачивание последовательных пробелов в один (false | true | inherit) -->
        <xsl:attribute name="white-space-collapse">false</xsl:attribute>

        <!-- Обработка пробелов и символов форматирования строк (ignore | preserve | ignore-if-before-linefeed | -->
        <!-- ignore-if-after-linefeed | ignore-if-surrounding-linefeed | inherit) -->
        <xsl:attribute name="white-space-treatment">inherit</xsl:attribute>

        <!-- Подобно wrap-option работает с символами перевода строки / linefeeds -->
        <!-- (ignore | preserve | treat-as-space | treat-as-zero-width-space | inherit) -->
        <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>

        <!-- Расстояния между параграфами (до и после), заданные здесь значения влияют на -->
        <!-- величину empty-line во ВСЁМ документе, как и literallayout в fb2docbook.xsl -->
        <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>

    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Стилевой тэг code, по назначению аналогичен таковому в html -->
    <!-- (для fb:code, заданному как xsl:element name="code" в fb2docbook.xsl) -->

    <xsl:attribute-set name="monospace.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">
            <xsl:value-of select="$monospace.font.family"/>
        </xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.8"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">normal</xsl:attribute>

    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Тэг code, используемый как pre в html - для листингов программ -->
    <!-- (для fb:code, заданному как xsl:element name="programlisting" в fb2docbook.xsl) -->

    <xsl:attribute-set name="monospace.verbatim.properties">

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">
            <xsl:value-of select="$monospace.font.family"/>
        </xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.6"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">normal</xsl:attribute>

        <!-- Отступ первой строки абзаца (размер | проценты | inherit) -->
        <xsl:attribute name="text-indent">0pt</xsl:attribute>

        <!-- Выравнивание текста (start | center | end | justify | left | right | inside | outside) -->
        <xsl:attribute name="text-align">start</xsl:attribute>

        <!-- Поля текстового блока (размер | inherit) -->
        <xsl:attribute name="margin-left">10pt</xsl:attribute>

        <!-- Расстановка переносов (false | true | inherit) -->
        <xsl:attribute name="hyphenate">false</xsl:attribute>

        <!-- Разрыв строк (wrap | no-wrap | inherit) -->
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>

        <!-- Сворачивание последовательных пробелов в один (false | true | inherit) -->
        <xsl:attribute name="white-space-collapse">false</xsl:attribute>

        <!-- Обработка пробелов и символов форматирования строк (ignore | preserve | ignore-if-before-linefeed | -->
        <!-- ignore-if-after-linefeed | ignore-if-surrounding-linefeed | inherit) -->
        <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>

        <!-- Подобно wrap-option работает с символами перевода строки / linefeeds -->
        <!-- (ignore | preserve | treat-as-space | treat-as-zero-width-space | inherit) -->
        <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>

        <!-- Расстояния между параграфами (до и после) -->
        <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>

    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Заголовок аннотаций (если нет abstract.title.properties), и наверняка ещё чего-то -->

    <xsl:attribute-set name="formal.title.properties" use-attribute-sets="normal.para.spacing">

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.88"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>

        <!-- Вес (жирность) шрифта (normal | bold) -->
        <xsl:attribute name="font-weight">bold</xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">italic</xsl:attribute>

        <!-- Расстановка переносов (false | true | inherit) -->
        <xsl:attribute name="hyphenate">false</xsl:attribute>

        <!-- Расстояния между параграфами (до и после) -->
        <xsl:attribute name="space-before.minimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.2em</xsl:attribute>

    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Родительские элементы таблиц, и наверняка ещё чего-то -->

    <xsl:attribute-set name="formal.object.properties">

        <!-- Расстояния между параграфами (до и после) -->
        <xsl:attribute name="space-before.minimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.2em</xsl:attribute>

        <!-- Разрыв страниц: сохранить объект на одной странице (auto | always | целое | inherit) -->
        <xsl:attribute name="keep-together.within-column">always</xsl:attribute>

    </xsl:attribute-set>


    <xsl:attribute-set name="informal.object.properties">

        <!-- Расстояния между параграфами (до и после) -->
        <xsl:attribute name="space-before.minimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.2em</xsl:attribute>

    </xsl:attribute-set>


<!-- ==================================================================== -->


    <!-- Таблицы -->

    <xsl:attribute-set name="table.table.properties">

        <!-- Управление структурированием ячеек, рядов и столбцов таблицы (auto | fixed | inherit) -->
        <xsl:attribute name="table-layout">fixed</xsl:attribute>
        <xsl:attribute name="width">
            <xsl:value-of select="$default.table.width"/>
        </xsl:attribute>

        <!-- Семейство шрифта (имя | тип | inherit) -->
        <xsl:attribute name="font-family">
            <xsl:value-of select="$title.font.family"/>
        </xsl:attribute>

        <!-- Размер шрифта (абсолютный | относительный | независимый | проценты | inherit) -->
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.5"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>

        <!-- Вес (жирность) шрифта (normal | bold) -->
        <xsl:attribute name="font-weight">normal</xsl:attribute>

        <!-- Начертание (наклон) шрифта (normal | italic) -->
        <xsl:attribute name="font-style">normal</xsl:attribute>

        <!-- Отступ текста от начального края (левый по умолчанию; размер | проценты | inherit) -->
        <xsl:attribute name="start-indent">0pt</xsl:attribute>

        <!-- Отступ первой строки абзаца (размер | проценты | inherit) -->
        <xsl:attribute name="text-indent">0pt</xsl:attribute>

        <!-- Выравнивание текста (start | center | end | justify | left | right | inside | outside) -->
        <xsl:attribute name="text-align">center</xsl:attribute>

        <!-- Расстановка переносов (false | true | inherit) -->
        <xsl:attribute name="hyphenate">true</xsl:attribute>

        <!-- Разрыв строк (wrap | no-wrap | inherit) -->
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>

        <!-- Расстояния между параграфами (до и после) -->
        <xsl:attribute name="space-before.minimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.2em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.2em</xsl:attribute>

    </xsl:attribute-set>


    <!-- Расстояние между границами ячейки и её содержимым -->
    <xsl:attribute-set name="table.cell.padding">

        <xsl:attribute name="padding-left">1pt</xsl:attribute>
        <xsl:attribute name="padding-right">1pt</xsl:attribute>
        <xsl:attribute name="padding-top">1pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">1pt</xsl:attribute>

    </xsl:attribute-set>


    <!-- Шаблон таблицы: свойства ячеек -->
    <xsl:template name="table.cell.properties">

        <!-- Вертикальное выравнивание текста (before | center | after) -->
        <xsl:attribute name="display-align">center</xsl:attribute>

        <!-- Ширина границ (размер | inherit) -->
        <xsl:attribute name="border-width">0.5pt</xsl:attribute>

        <!-- Стиль границ (none | dotted | dashed | solid | double | groove | ridge | inherit) -->
        <xsl:attribute name="border-style">solid</xsl:attribute>

        <!-- Цвет границ (цвет | transparent | inherit) -->
        <xsl:attribute name="border-color">#000000</xsl:attribute>

        <!-- Цвет фона (цвет | transparent | inherit) -->
        <xsl:attribute name="background-color">#F8F8FF</xsl:attribute>

    </xsl:template>


<!-- ==================================================================== -->


    <!-- Настройка стиля ссылок -->

    <xsl:attribute-set name="xref.properties">
        <!-- Цвет ссылок в тексте -->
        <xsl:attribute name="color">
          <xsl:choose>
            <xsl:when test="self::ulink">#0000CD</xsl:when>
            <xsl:when test="self::link">#191970</xsl:when>
            <xsl:otherwise>inherit</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>


<!-- ==================================================================== -->

</xsl:stylesheet>
