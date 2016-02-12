import std.stdio;
import hibernated.core;

enum WEPON: string {
    SWORD = "Sword",
    LANCE = "Lance",
    HAMMER = "Hammer",
    GUN = "Gun",
    WAND = "Wand"
}

class Character {
    @Id @UniqueKey @Generator(UUID_GENERATOR) {
        string id;
    }

    @NotNull {
        string name;
        ubyte grade;
        bool affection;
    }

    @OneToMany {
        LazyCollection!Card cards;
    }
}

class Status {
    @Id @UniqueKey @Generator(UUID_GENERATOR) {
        string id;
    }

    @NotNull {
        ushort hit;
        ushort skill;
        ushort attack;
        ushort defense;
    }
}

class Wepon {
    @Id @UniqueKey @Generator(UUID_GENERATOR) {
        string id;
    }

    @NotNull {
        string kind;
    }

    @NotNull @OneToMany {
        LazyCollection!Card cards;
    }
}

class Card {
    @Id @UniqueKey @Generator(UUID_GENERATOR) {
        string id;
    }

    @NotNull @ManyToOne {
        Character character;
        Wepon wepon;
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

    auto schema = new SchemaInfoImpl!(Card, Character, Status, Wepon);
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

    Character character = new Character();
    character.name = "test子";
    character.grade = 6;
    character.affection = false;

    Status status50 = new Status();
    status50.hit = 100;
    status50.skill = 100;
    status50.attack = 100;
    status50.defense = 100;

    Status status70 = new Status();
    status70.hit = 200;
    status70.skill = 200;
    status70.attack = 200;
    status70.defense = 200;

    Wepon wepon = new Wepon();
    wepon.kind = "Sword";

    Card card = new Card();
    card.character = character;
    card.wepon = wepon;
    card.l50 = status50;
    card.l70 = status70;

    sess.save(character);
    sess.save(wepon);
    sess.save(status50);
    sess.save(status70);
    sess.save(card);

    auto qr = sess.createQuery("FROM Card");
    writeln(qr.listRows());
    Card c = qr.uniqueResult!Card();
    writeln(c);

	writeln("Edit source/app.d to start your project.");
}
