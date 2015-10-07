create type field_value_kind as enum (
    'int',
    'text',
    'timestamp',
    'boolean'
);

create table field (
    id serial primary key,
    key text not null,
    label text not null,
    kind field_value_kind not null
);

create table entity (
    id bigserial primary key
);

create table attribute (
    id bigserial primary key,
    entity bigint not null references entity (id),
    field int not null references field (id),
    time_set timestamp with time zone not null default now()
);

-- Allows timestamps of attributes to be retrospectively adjusted
create table attribute_time_override (
    id bigserial primary key,
    attribute bigint not null references attribute (id),
    time_set timestamp with time zone not null default now(),
    time_effective timestamp with time zone not null
);

create table int_attribute (
    attribute bigint not null references attribute (id),
    int_value bigint
);
create table text_attribute (
    attribute bigint not null references attribute (id),
    text_value text
);
create table timestamp_attribute (
    attribute bigint not null references attribute (id),
    timestamp_value timestamp
);
create table boolean_attribute (
    attribute bigint not null references attribute (id),
    boolean_value boolean
);
create view current_attribute as
select max(id) as id, entity, field from attribute group by entity, field;

create view current_attribute_with_fields as
select ca.id, entity, field, key, label, kind from current_attribute ca inner join field f on f.id = ca.field;

create view current_int_attribute_with_fields as
select * from current_attribute_with_fields a inner join int_attribute int on int.attribute = a.id;
