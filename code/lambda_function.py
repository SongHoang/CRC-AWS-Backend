import json
import boto3
from boto3.dynamodb.conditions import Key, Attr


#always start with the lambda_handler
def lambda_handler(event, context):
    
    # make the connection to dynamodb
    dynamodb = boto3.resource('dynamodb')

    # select the table
    table = dynamodb.Table("DynamoDB-Terraform")

    # get item from database
    items = table.get_item(Key={"Website": "CRC"})

    items = table.update_item(
        Key={"Website": "CRC"},
        UpdateExpression="set Visitors = Visitors + :n",
        ExpressionAttributeValues={
            ":n": 1,
        },
        ReturnValues="UPDATED_NEW",
    )

    print(items)
    return(items)