import std.stdio;
import std.json;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.range;
import std.array;
import hibernated.core;

alias hibernated.annotations.Generator hGenerator;

class Grade {
    @Id @UniqueKey @hGenerator(UUID_GENERATOR) {
        string id;
    }

    @NotNull {
        char w;
        ubyte n;
    }

    @NotNull @OneToMany {
        LazyCollection!Character characters;
    }
}

class Character {
    @Id @UniqueKey @hGenerator(UUID_GENERATOR) {
        string id;
    }

    @NotNull {
        string name;
    }

    @NotNull @ManyToOne {
        Grade grade;
    }

    @NotNull @OneToMany {
        LazyCollection!Card cards;
    }
}

class Wepon {
    @Id @UniqueKey @hGenerator(UUID_GENERATOR) {
        string id;
    }

    @NotNull {
        string kind;
    }

    @NotNull @OneToMany {
        LazyCollection!Card cards;
    }
}

class Category {
     @Id @UniqueKey @hGenerator(UUID_GENERATOR) {
        string id;
    }

    @NotNull {
        string kind;
    }

    @NotNull @OneToMany {
        LazyCollection!Card cards;
    }
}

class Status {
    @Id @UniqueKey @hGenerator(UUID_GENERATOR) {
        string id;
    }

    @NotNull {
        ushort hit;
        ushort skill;
        ushort attack;
        ushort defense;
    }
}

class Card {
    @Id @UniqueKey @hGenerator(UUID_GENERATOR) {
        string id;
    }

    @NotNull @ManyToOne {
        Character character;
        Wepon wepon;
        Category category;
    }

    @NotNull @JoinColumn {
        Status l50;
        Status l70;
    }
}

void main()
{
    auto driver = new SQLITEDriver();
    string[string] params;
    auto ds = new ConnectionPoolDataSourceImpl(driver, "test.db", params);
    auto dialect = new SQLiteDialect();

    auto schema = new SchemaInfoImpl!(Card, Character, Status, Wepon, Grade, Category);
    auto factory = new SessionFactoryImpl(schema, dialect, ds);
    scope(exit) factory.close();
    auto db = factory.getDBMetaData();
    {
        auto conn = ds.getConnection();
        scope(exit) conn.close();
        db.updateDBSchema(conn, true, true);
    }

    auto sess = factory.openSession();
    scope(exit) sess.close();

    auto json = parseJSON(readText("seed.json"));

    Grade[string] grades;
    foreach( obj; json["Grade"].array ) {
        auto grade = new Grade();
        grade.w = obj["w"].str.to!char;
        grade.n = obj["n"].integer.to!ubyte;
        sess.save(grade);
        grades[obj["_id"].str] = grade;
    }

    Character[string] characters;
    foreach( obj; json["Character"].array ) {
        auto character = new Character();
        character.name = obj["name"].str;
        character.grade = grades[obj["grade"].str];
        sess.save(character);
        characters[obj["_id"].str] = character;
    }

    Wepon[string] wepons;
    foreach( obj; json["Wepon"].array ) {
        auto wepon = new Wepon();
        wepon.kind = obj["kind"].str;
        sess.save(wepon);
        wepons[obj["_id"].str] = wepon;
    }

    Category[string] categories;
    foreach( obj; json["Category"].array ) {
        auto category = new Category();
        category.kind = obj["kind"].str;
        sess.save(category);
        categories[obj["_id"].str] = category;
    }

    Status[string] statuses;
    foreach( obj; json["Status"].array ) {
        auto status = new Status();
        status.hit = obj["hit"].integer.to!ushort;
        status.skill = obj["skill"].integer.to!ushort;
        status.attack = obj["attack"].integer.to!ushort;
        status.defense = obj["defense"].integer.to!ushort;
        sess.save(status);
        statuses[obj["_id"].str] = status;
    }

    Card[] cards;
    foreach( obj; json["Card"].array ) {
        auto card = new Card();
        card.character = characters[obj["character"].str];
        card.wepon = wepons[obj["wepon"].str];
        card.category = categories[obj["category"].str];
        card.l50 = statuses[obj["l50"].str];
        card.l70 = statuses[obj["l70"].str];
        sess.save(card);
        cards ~= card;
    }

    auto qr = sess.createQuery("FROM Card");
    writeln(qr.listRows());
    Card c = qr.uniqueResult!Card();
    writeln(c);
    writeln(c.character.name);
    writeln(c.wepon.kind);
    writeln(c.category.kind);

	writeln("Edit source/app.d to start your project.");
}
