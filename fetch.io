SGML

url := URL with("http://wiki.dengekionline.com/battlegirl/%E3%82%AB%E3%83%BC%E3%83%89%E4%B8%80%E8%A6%A7")
data := url fetch asHTML

cards := data elementWithName("body") elementsWithNameAndId("div", "wiki-content") first elementsWithName("tr")

cards := cards select( subitems at(1) elementWithName("span") asString asHex == "3c7370616e207374796c653d22636f6c6f723a6f72616e6765223ee29885e29885e29885e298853c2f7370616e3e" )

maps := cards foreach( i, v,
    a := v subitems at(0) subitems at(0)

    title := a attribute("title")
    category := title betweenSeq("【", "】")
    name := title split("】") at(1) asMutable strip

    page := URL with( "http://wiki.dengekionline.com" .. a attribute("href")) fetch asHTML
    param_div := page elementsWithNameAndId("div", "wiki-content") first elementsWithNameAndClass("div", "ie5") at(1)
    tbody := param_div elementWithName("tbody")

    Map clone do (
        atPut("category", category)
        atPut("name", name)
        atPut("lv50", tbody subitems at(2) subitems map(allText) slice(1))
        atPut("lv70", tbody subitems at(3) subitems map(allText) slice(1))
    )
)

