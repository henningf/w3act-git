Dockerfile for running w3act
==============================================

I got w3act from [UKWA w3act](https://github.com/ukwa/w3act)

w3act is setup to run with a postgres database, to test this dockerfile just run:

Added auto-creation of prod.conf, environment variables that can be set are:
POSTGRES_USER  
POSTGRES_PASSWORD  
POSTGRES_HOST  
POSTGRES_DB  
W3ACT_SECRET  
PRIVACY_STATEMENT  
W3ACT_SERVER_NAME  
AMQP_QUEUE_HOST  
AMQP_QUEUE_PORT  
AMQP_QUEUE_NAME  
AMQP_ROUTING_KEY  
AMQP_EXCHANGE_NAME  
APPLICATION_WAYBACK_URL  
APPLICATION_WAYBACK_QUERY_PATH  
APPLICATION_ACCESS_RESOLVER_URL  
APPLICATION_MONITRIX_URL  
APPLICATION_PDFTOHTMLEX_URL  
ADMIN_DEFAULT_EMAIL  
W3ACT_USE_ACCOUNTS  



```
# Create w3act docker-container
docker build -t w3act .

# Start postgres
docker run -d --name postgres -e POSTGRES_PASSWORD=training -e POSTGRES_USER=training -e POSTGRES_DB=w3act postgres:9.3.12 

# Start w3act
docker run -d --name w3act --link postgres:postgres -e POSTGRES_HOST=postgres -e POSTGRES_USER=training -e POSTGRES_PASSWORD=training -e POSTGRES_DB=w3act -p 9000:9000 w3act

# To get testdata into the database run:
docker exec -it w3act bash
java -cp "/opt/w3act/lib/*" -Dconfig.file=conf/prod.conf uk.bl.db.DataImport
```

Now w3act should be up on localhost:9000, and you can log into it with the users that was imported from the
testdata-accounts.yml file (located in the conf directory)
