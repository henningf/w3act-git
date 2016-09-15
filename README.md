Dockerfile for running w3act in docker
==============================================

I got w3act from [UKWA w3act](https://github.com/ukwa/w3act)

w3act is setup to run with a postgres database, to test this dockerfile just run:

```
# Create w3act docker-container
docker build -t w3act .

# Start postgres
docker run -d --name postgres -e POSTGRES_PASSWORD=training -e POSTGRES_USER=training -e POSTGRES_DB=w3act postgres:9.3.12 

# Start w3act
docker run -d --name w3act --link postgres:postgres -e POSTGRES_HOST=postgres -e POSTGRES_USER=training -e PGPASSWORD=training -e POSTGRES_DB=w3act -p 9000:9000 w3act

# To get testdata into the database run:
docker exec -it w3act bash
java -cp "/opt/w3act/lib/*" -Dconfig.file=conf/prod.conf uk.bl.db.DataImport
```

Now w3act should be up on localhost:9000, and you can log into it with the users that was imported from the
testdata-accounts.yml file (located in the conf directory)
