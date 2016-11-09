#!/usr/bin/env python
"""
Simple python script, reads environment variables and passes them to a template.
"""

from shutil import copyfile
import os
from jinja2 import Environment, FileSystemLoader

# Turn environment variables into regular python variables
application_secret = os.environ['W3ACT_SECRET']
postgres_host = os.environ['POSTGRES_HOST']
postgres_user = os.environ['POSTGRES_USER']
postgres_passwd = os.environ['POSTGRES_PASSWORD']
postgres_database = os.environ['POSTGRES_DB']
privacy_statement = os.environ['PRIVACY_STATEMENT']
w3act_server_name = os.environ['W3ACT_SERVER_NAME']
amqp_queue_host = os.environ['AMQP_QUEUE_HOST']
amqp_queue_port = os.environ['AMQP_QUEUE_PORT']
amqp_queue_name = os.environ['AMQP_QUEUE_NAME']
amqp_routing_key = os.environ['AMQP_ROUTING_KEY']
amqp_exchange_name = os.environ['AMQP_EXCHANGE_NAME']
application_wayback_url = os.environ['APPLICATION_WAYBACK_URL']
application_wayback_query_path = os.environ['APPLICATION_WAYBACK_QUERY_PATH']
application_access_resolver_url = os.environ['APPLICATION_ACCESS_RESOLVER_URL']
application_monitrix_url = os.environ['APPLICATION_MONITRIX_URL']
application_pdftohtmlex_url = os.environ['APPLICATION_PDFTOHTMLEX_URL']
admin_default_email = os.environ['ADMIN_DEFAULT_EMAIL']
w3act_use_accounts = os.environ['W3ACT_USE_ACCOUNTS']


# Create template
template_env = Environment(loader=FileSystemLoader('/opt/w3act/bin/jinjatemplates'))
prod_template = template_env.get_template('prod.conf.j2')
output_from_parsed_prod_template = prod_template.render(
    application_secret=application_secret,
    postgres_host=postgres_host,
    postgres_user=postgres_user,
    postgres_passwd=postgres_passwd,
    postgres_database=postgres_database,
    privacy_statement=privacy_statement,
    w3act_server_name=w3act_server_name,
    amqp_queue_host=amqp_queue_host,
    amqp_queue_port=amqp_queue_port,
    amqp_queue_name=amqp_queue_name,
    amqp_routing_key=amqp_routing_key,
    amqp_exchange_name=amqp_exchange_name,
    application_wayback_url=application_wayback_url,
    application_wayback_query_path=application_wayback_query_path,
    application_access_resolver_url=application_access_resolver_url,
    application_monitrix_url=application_monitrix_url,
    application_pdftohtmlex_url=application_pdftohtmlex_url,
    admin_default_email=admin_default_email,
    w3act_use_accounts=w3act_use_accounts
    )

# Write template to prod.conf
with open("/opt/w3act/conf/prod.conf", "wb") as fh:
    fh.write(output_from_parsed_prod_template)
