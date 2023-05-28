import os
import random
import requests
import boto3
import time
import json

BUCKET_NAME = os.environ.get('BUCKET_NAME', 'ucu-faas-files-bucket')
API_URL = os.environ.get('ULR', 'https://5csrv4u42g.execute-api.us-west-2.amazonaws.com/v1/api')


def test_unauthroized():

    # DO Request
    headers =  {'Content-Type': 'application/json;'}
    body = {
        'question': random.randint(0, 1e3)
    }

    response = requests.post(url=API_URL, headers=headers, json=body)

    assert response.text == "Unauthorized"
    assert response.status_code == 401


def test_authorized():
    s3_client = boto3.resource("s3")
    bucket = s3_client.Bucket(BUCKET_NAME)

    # DO Request
    headers =  {
        'Content-Type': 'application/json',
        'token': 'authtoken'
    }
    body = {
        'question': random.randint(0, 1e3)
    }

    response = requests.post(url=API_URL, headers=headers, json=body).json()

    # wait for some time until new object will be created
    created = False
    it = 0
    while it < 10:
        it+=1
        # find files with required name
        files = list(bucket.objects.filter(Prefix=f'data-'))
        files = list(filter(lambda x: x.key == f'data-{response["id"]}.json', files))
        if files:
            file_body = json.loads(files[0].get()['Body'].read())
            assert file_body['question'] == body['question']
            created = True
            break
        time.sleep(1)        
    assert created, "File should be created"


test_unauthroized()
test_authorized()
