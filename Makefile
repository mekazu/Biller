clean:
	dropdb biller
	createdb biller
	psql -1 -f etc/create.sql biller
populate: clean
	psql -1 -f etc/populate.sql biller
