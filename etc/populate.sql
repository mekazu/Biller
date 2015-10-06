insert into field (key, label, kind) values ('status', 'Status', 'boolean');
insert into field (key, label, kind) values ('type', 'Type', 'text');
insert into entity (kind) values ('foo');
insert into attribute (entity, field) select 1, id from field where key = 'status';
insert into boolean_attribute (attribute, boolean_value) select id, false from attribute order by id desc limit 1;
insert into attribute (entity, field) select 1, id from field where key = 'status';
insert into boolean_attribute (attribute, boolean_value) select id, true from attribute order by id desc limit 1;
insert into attribute (entity, field) select 1, id from field where key = 'type';
insert into text_attribute (attribute, text_value) select id, 'Bridge' from attribute order by id desc limit 1;

