Fixed following list of warning.



```
Check: CKV_AWS_338: "Ensure CloudWatch log groups retains logs for at least 1 year"
	FAILED for resource: aws_cloudwatch_log_group.api_event_api_gateway
	File: /api_gateway.tf:5-10
```


```
Check: CKV_AWS_309: "Ensure API GatewayV2 routes specify an authorization type"
	FAILED for resource: aws_apigatewayv2_route.api_event
	File: /api_gateway.tf:30-35
		30 | resource "aws_apigatewayv2_route" "api_event" {
		31 |   api_id    = aws_apigatewayv2_api.api_event.id
		32 |   route_key = "POST /api"
		33 | 
		34 |   target = "integrations/${aws_apigatewayv2_integration.api_event.id}"
		35 | }
```


```
Check: CKV_AWS_108: "Ensure IAM policies does not allow data exfiltration"
	FAILED for resource: aws_iam_policy_document.db_lambda
	File: /iam.tf:193-213
	Guide: https://docs.bridgecrew.io/docs/ensure-iam-policies-do-not-allow-data-exfiltration
		193 | data "aws_iam_policy_document" "db_lambda" {
		194 | 
		195 |   statement {
		196 |     actions = [
		197 |       "cloudwatch:ListTagsForResource",
		198 |       "secretsmanager:GetSecretValue"
		199 |     ]
		200 | 
		201 |     resources = ["*"]
		202 |   }
		203 | 
		204 |   statement {
		205 |     actions = [
		206 |       "logs:CreateLogStream",
		207 |       "logs:PutLogEvents"
		208 |     ]
		209 | 
		210 |     resources = ["${aws_cloudwatch_log_group.db_lambda.arn}:*"]
		211 |   }
		212 | 
		213 | }
```

```
Check: CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"
	FAILED for resource: aws_iam_policy_document.api_event_lambda
	File: /iam.tf:68-88
	Guide: https://docs.bridgecrew.io/docs/ensure-iam-policies-do-not-allow-write-access-without-constraint
		68 | data "aws_iam_policy_document" "api_event_lambda" {
		69 | 
		70 |   statement {
		71 |     actions = [
		72 |       "cloudwatch:ListTagsForResource",
		73 |       "events:PutEvents"
		74 |     ]
		75 | 
		76 |     resources = ["*"]
		77 |   }
		78 | 
		79 |   statement {
		80 |     actions = [
		81 |       "logs:CreateLogStream",
		82 |       "logs:PutLogEvents"
		83 |     ]
		84 | 
		85 |     resources = ["${aws_cloudwatch_log_group.api_event_lambda.arn}:*"]
		86 |   }
		87 | 
		88 | }
```

and others...