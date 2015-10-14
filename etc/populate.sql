insert into field (key, label, kind) values ('status', 'Status', 'boolean');
insert into field (key, label, kind) values ('type', 'Type', 'text');
insert into field (key, label, kind) values ('parent', 'Parent', 'int');
insert into field (key, label, kind) values ('related', 'Related', 'int'); -- Related entity - used by Link entities
insert into field (key, label, kind) values ('amount', 'Amount in cents, debits are negative', 'int');

-- Entity 1 - Client
insert into entity values (default);
insert into attribute (entity, field) select 1, id from field where key = 'status';
insert into boolean_attribute (attribute, boolean_value) select id, false from attribute order by id desc limit 1;
insert into attribute (entity, field) select 1, id from field where key = 'status';
insert into boolean_attribute (attribute, boolean_value) select id, true from attribute order by id desc limit 1;
insert into attribute (entity, field) select 1, id from field where key = 'type';
insert into text_attribute (attribute, text_value) select id, 'Client' from attribute order by id desc limit 1;

-- Entity 2 - ADSL
insert into entity values (default);
insert into attribute (entity, field) select 2, id from field where key = 'type';
insert into text_attribute (attribute, text_value) select id, 'ADSL' from attribute order by id desc limit 1;
insert into attribute (entity, field) select 2, id from field where key = 'status';
insert into boolean_attribute (attribute, boolean_value) select id, true from attribute order by id desc limit 1;
insert into attribute (entity, field) select 2, id from field where key = 'parent';
insert into int_attribute (attribute, int_value) select id, 1 from attribute order by id desc limit 1;

-- Entity 3 - Telephony
insert into entity values (default);
insert into attribute (entity, field) select 3, id from field where key = 'type';
insert into text_attribute (attribute, text_value) select id, 'Telephony' from attribute order by id desc limit 1;
insert into attribute (entity, field) select 3, id from field where key = 'status';
insert into boolean_attribute (attribute, boolean_value) select id, true from attribute order by id desc limit 1;
insert into attribute (entity, field) select 3, id from field where key = 'parent';
insert into int_attribute (attribute, int_value) select id, 1 from attribute order by id desc limit 1;

-- Entity 4 - Bundle between ADSL and Telephony
insert into entity values (default);
insert into attribute (entity, field) select 4, id from field where key = 'type';
insert into text_attribute (attribute, text_value) select id, 'Bundle' from attribute order by id desc limit 1;

-- Entity 5 - Link between ADSL and Bundle
insert into entity values (default);
insert into attribute (entity, field) select 5, id from field where key = 'type';
insert into text_attribute (attribute, text_value) select id, 'Link' from attribute order by id desc limit 1;
insert into attribute (entity, field) select 5, id from field where key = 'parent';
insert into int_attribute (attribute, int_value) select id, 4 from attribute order by id desc limit 1;
insert into attribute (entity, field) select 5, id from field where key = 'related';
insert into int_attribute (attribute, int_value) select id, 2 from attribute order by id desc limit 1;

-- Entity 6 - Link between Telephony and Bundle
insert into entity values (default);
insert into attribute (entity, field) select 6, id from field where key = 'type';
insert into text_attribute (attribute, text_value) select id, 'Link' from attribute order by id desc limit 1;
insert into attribute (entity, field) select 6, id from field where key = 'parent';
insert into int_attribute (attribute, int_value) select id, 4 from attribute order by id desc limit 1;
insert into attribute (entity, field) select 6, id from field where key = 'related';
insert into int_attribute (attribute, int_value) select id, 3 from attribute order by id desc limit 1;

-- Entity 7 - Mobile Data
insert into entity values (default);
insert into attribute (entity, field) select 7, id from field where key = 'type';
insert into text_attribute (attribute, text_value) select id, 'Mobile Data' from attribute order by id desc limit 1;
insert into attribute (entity, field) select 7, id from field where key = 'parent';
insert into int_attribute (attribute, int_value) select id, 1 from attribute order by id desc limit 1;

-- Entity 8 - Link between Mobile Data and Bundle
insert into entity values (default);
insert into attribute (entity, field) select 8, id from field where key = 'type';
insert into text_attribute (attribute, text_value) select id, 'Link' from attribute order by id desc limit 1;
insert into attribute (entity, field) select 8, id from field where key = 'parent';
insert into int_attribute (attribute, int_value) select id, 4 from attribute order by id desc limit 1;
insert into attribute (entity, field) select 8, id from field where key = 'related';
insert into int_attribute (attribute, int_value) select id, 7 from attribute order by id desc limit 1;

-- Entity 9 - Phoneline between ADSL and Telephony
insert into entity values (default);
insert into attribute (entity, field) select 9, id from field where key = 'type';
insert into text_attribute (attribute, text_value) select id, 'Phoneline' from attribute order by id desc limit 1;

-- Entity 10 - Link between Telephony and Phoneline
insert into entity values (default);
insert into attribute (entity, field) select 10, id from field where key = 'parent';
insert into int_attribute (attribute, int_value) select id, 9 from attribute order by id desc limit 1;
insert into attribute (entity, field) select 10, id from field where key = 'related';
insert into int_attribute (attribute, int_value) select id, 3 from attribute order by id desc limit 1;

-- Entity 11 - Link between Telephony and Phoneline
insert into entity values (default);
insert into attribute (entity, field) select 11, id from field where key = 'parent';
insert into int_attribute (attribute, int_value) select id, 9 from attribute order by id desc limit 1;
insert into attribute (entity, field) select 11, id from field where key = 'related';
insert into int_attribute (attribute, int_value) select id, 4 from attribute order by id desc limit 1;

