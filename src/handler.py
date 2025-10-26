import json
import os

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({
            "message": "Container Lambda deployed from develop!",
            "function": os.environ.get("AWS_LAMBDA_FUNCTION_NAME"),
            "version": os.environ.get("AWS_LAMBDA_FUNCTION_VERSION")
        })
    }
