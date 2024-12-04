data "archive_file" "python_lambda_package" {  
  type = "zip"  
  source_file = "${path.module}/code/lambda_function.py" 
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "test_lambda_function" {
        function_name = "lambdaTest"
        filename      = "lambda.zip"
        source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
        role          = aws_iam_role.lambda_role.arn
        runtime       = "python3.9"
        handler       = "lambda_function.lambda_handler"
        timeout       = 10
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
    {
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }
  ]
})
}

resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "DynamoDB_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({

	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"lambda:InvokeFunction"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"dynamodb:DescribeStream",
				"dynamodb:GetRecords",
				"dynamodb:GetShardIterator",
				"dynamodb:ListStreams",
				"dynamodb:UpdateItem"
			],
			"Resource": "*"
		}
	]
    
  })
}


# Fetch an AWS Managed Policy ARN
data "aws_iam_policy" "dynamodb_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

# Attach the fetched policy to the role
resource "aws_iam_role_policy_attachment" "readonlyaccess" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

data "aws_iam_policy" "lambda_basic_exec" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.lambda_role.name
}

