import os
import boto3
import json
import logging
import uuid

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

