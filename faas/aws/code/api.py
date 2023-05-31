import os
import boto3
import json
import logging
import uuid

import random


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def check_auth(event):
    if 'headers' in event:
        if 'token' in event['headers']:
            if event['headers']['token'] == 'authtoken':
                return True
    return False



def api_lambda_handler(event, context):
    logger.info("Event: " + str(event))
    # TODO implement
    
    if not check_auth(event):
        return {
            'statusCode': 401,
            'headers': {"content-type": "application/json"},
            'body': 'Unauthorized',
        }


    payload = json.loads(event['body'])
    payload['id'] = str(uuid.uuid4())

    event_client = boto3.client(
        'events',
        region_name='us-west-2',
        # aws_access_key_id=os.environ['ACCESS_KEY'],
        # aws_secret_access_key=os.environ['SECRET_KEY']
    )

    response = event_client.put_events(
        Entries=[
            {
                'Source':'api.event',
                'DetailType':'custom',
                'Detail': json.dumps(payload),
                'EventBusName': os.environ['EVENT_BUS'],
            }
        ]
    )
    event['response'] = response
        # print(response)

    return {
        'statusCode': 200,
        'headers': {"content-type": "application/json"},
        'body': json.dumps(payload)
    }

    

def event_lambda_handler(event, context):
    logger.info("Event: " + str(event))
    payload = event['detail']
    s3_client = boto3.resource("s3")
    s3_path = f"data-{payload['id']}.json"
    bucket = s3_client.Bucket(os.environ['BUCKET_NAME'])

    files = list(bucket.objects.filter(Prefix=s3_path))
    
    if not len(files):
        bucket.put_object(Key=s3_path, Body=json.dumps(payload, indent=2))
    else:
        logger.error(f"{s3_path} file exists...")


    return {
        'statusCode': 200,
    }


def get_credentials():
    credential = {}
    
    secret_name = os.environ['DB_SECRET_NAME']
    region_name = "us-west-2" # FIXME
    
    client = boto3.client(
      service_name='secretsmanager',
      region_name=region_name
    )
    
    get_secret_value_response = client.get_secret_value(
      SecretId=secret_name
    )
    
    secret = json.loads(get_secret_value_response['SecretString'])
    
    # credential['username'] = secret['username']
    # credential['password'] = secret['password']
    
    return secret


QUERY_CREATE_TABLE = """CREATE TABLE IF NOT EXISTS data (
  id int,
  uuid VARCHAR(255) NOT NULL,
  data varchar
);"""

QUERY_INSERT_DATA = """INSERT INTO data (uuid, data)
VALUES ('{uuid}', '{data}')"""

def db_lambda_handler(event, context):
    import psycopg2 as pg
 
    payload = event['detail']
    credential = get_credentials()

    connection = pg.connect(
        user=credential['username'], 
        password=credential['password'], 
        host=credential['host'], 
        database=credential['database']
    )
    cursor = connection.cursor()
    # query = "SELECT version() AS version"

    # create table if not exists
    cursor.execute(QUERY_CREATE_TABLE)

    cursor.execute(QUERY_INSERT_DATA.format(
        uuid=payload['id'],
        data=json.dumps(payload)
    ))

    cursor.close()
    connection.commit()

