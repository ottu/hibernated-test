module models;

import hibernated.core;

class Grade {
    @Id @UniqueKey @Generator(UUID_GENERATOR) {
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
    @Id @UniqueKey @Generator(UUID_GENERATOR) {
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

class Category {
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

class Card {
    @Id @UniqueKey @Generator(UUID_GENERATOR) {
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
