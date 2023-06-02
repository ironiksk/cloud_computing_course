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
