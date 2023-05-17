import os
import boto3
import json
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


event_client = boto3.client(
    'events',
    region_name='us-west-2',
    # aws_access_key_id=os.environ['ACCESS_KEY'],
    # aws_secret_access_key=os.environ['SECRET_KEY']
)


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


    response = event_client.put_events(
        Entries=[
            {
                'Source':'api.event',
                'DetailType':'custom',
                'Detail': json.dumps(event),
                'EventBusName':'event-bus'
            }
        ]
    )
    event['response'] = response
        # print(response)

    return {
        'statusCode': 200,
        'headers': {"content-type": "application/json"},
        'body': json.dumps(event)
    }

    

def event_lambda_handler(event, context):
    logger.info(f'Hello World!')
    logger.info(f'## ENVIRONMENT VARIABLES: {os.environ}')
    logger.info(f'## EVENT: {event}')
    return {
        'statusCode': 200,
    }

