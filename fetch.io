SGML
Regex

url := URL with("http://wiki.dengekionline.com/battlegirl/%E3%82%AB%E3%83%BC%E3%83%89%E4%B8%80%E8%A6%A7")
data := url fetch asHTML

cards := data elementWithName("body") elementsWithNameAndId("div", "wiki-content") first elementsWithName("tr")

cards := cards select( subitems at(1) elementWithName("span") asString asHex == "3c7370616e207374796c653d22636f6c6f723a6f72616e6765223ee29885e29885e29885e298853c2f7370616e3e" )

json := Map clone do(
    atPut("Category", List clone)
    atPut("Status", List clone)
    atPut("Card", List clone)
)

char_map := Map clone do(
    atPut("みき", "Miki")
    atPut("昴", "Subaru")
    atPut("遥香", "Haruka")
    atPut("望", "Nozomi")
    atPut("ゆり", "Yuri")
    atPut("くるみ", "Kurumi")
    atPut("あんこ", "Anko")
    atPut("蓮華", "Renge")
    atPut("明日葉", "Asuha")
    atPut("桜", "Sakura")
    atPut("ひなた", "Hinata")
    atPut("サドネ", "Sadone")
    atPut("楓", "Kaede")
    atPut("ミシェル", "Mumi")
    atPut("心美", "Kokomi")
    atPut("うらら", "URR")
)

wepon_map := Map clone do(
    atPut("sword", "S")
    atPut("spear", "L")
    atPut("hummer", "H")
    atPut("gun", "G")
    atPut("rod", "W")
)

cards foreach( i, v,
    a := v subitems at(0) subitems at(0)

    title := a attribute("title")
    category := title betweenSeq("【", "】")
    name := title split("】") at(1) asMutable strip

    wepon := v subitems at(2) subitems at(0) attribute("title") findRegex(".*\/icon\/(.*)\.png") at(1)

    page := URL with( "http://wiki.dengekionline.com" .. a attribute("href")) fetch asHTML
    param_div := page elementsWithNameAndId("div", "wiki-content") first elementsWithNameAndClass("div", "ie5") at(1)
    tbody := param_div elementWithName("tbody")

    lv50 := tbody subitems at(2) subitems map(allText) slice(1)
    lv70 := tbody subitems at(3) subitems map(allText) slice(1)

    c := json at("Category")
    cl := c select(hasValue(category))
    cid := ""
    if( cl size == 0 ) then(
        r := Map clone do(
            atPut("_id", "C" .. c size asString)
            atPut("kind", category)
        )
        c push(r)
        cid = r at("_id")
    ) else(
        cid = cl first at("_id")
    )

    s := json at("Status")
    s50id := "S" .. s size asString
    s push( Map clone do(
        atPut("_id", s50id )
        atPut("hit", lv50 at(0) asNumber )
        atPut("skill", lv50 at(1) asNumber )
        atPut("attack", lv50 at(2) asNumber )
        atPut("defense", lv50 at(3) asNumber )
    ) )

    s70id := "S" .. s size asString
    s push( Map clone do(
        atPut("_id", s70id )
        atPut("hit", lv70 at(0) asNumber )
        atPut("skill", lv70 at(1) asNumber )
        atPut("attack", lv70 at(2) asNumber )
        atPut("defense", lv70 at(3) asNumber )
    ) )

//    name println
//    char_map at(name) println
//    wepon println
//    wepon_map at(wepon) println
//    cid println
//    s50id println
//    s70id println

    char := char_map at(name)
    if(char isNil) then(char := "unknown")
    card := Map clone do(
        atPut("character", char)
        atPut("wepon", wepon_map at(wepon))
        atPut("category", cid)
        atPut("l50", s50id)
        atPut("l70", s70id)
    )

//    card asJson println

    json at("Card") push(card)
)

json asJson println
