# Billing Resources

This repo is created to test billing counts in stage, to make sure we don't harm the billing count.

## How to Use
The purpose of this repo is to integrate it into stage/production and always expect the same resources count.

1. Integrate this repo and wait for the scan to complete.
2. Run the query in RDS (replace customer name):
```sql
	SELECT distinct resource_id, customer_name, account_id, framework_type
	FROM "platform-stage".customer_resources_billing
	where customer_name='zeinavshem4159'
	and account_id='agueta/billing-bc-zehavit'
	and scan_date > (NOW() - interval '24 hour')
	order by framework_type, resource_id;
```
3. Expect to get the following resources count by framework, **total of 39**:

| Framework | Count |
| :-------- | :--------: |
| Terraform | 29 |
| CloudFormation | 2 |
| Kubernetes | 2 |
| Serverless | 2 |
| Arm | 1 |
| Docker | 3 |
| **Total** | **39** |

4. If you wish you can compare the resources with the [expected resources list](expected-resources.csv).


## Maintaining This Repo
Since this repo is meant to preserve consistency we must not modify it without updating the README.
If you modify it you need to update:
1. Framework counts + total count.
2. Export a new [expected resources list](expected-resources.csv).
