clean:
	dropdb biller

create:
	createdb biller
	psql -1 -f etc/create.sql biller

populate:
	psql -1 -f etc/populate.sql biller
