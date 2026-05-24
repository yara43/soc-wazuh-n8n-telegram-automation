# n8n Workflow Exports

Export the real workflow from n8n and save it here.

Recommended file name:

```text
workflows/wazuh-alert-intake.json
```

## How to export from n8n

1. Open n8n:

   ```text
   http://192.168.86.146:5678
   ```

2. Open the workflow:

   ```text
   Wazuh Alert Intake
   ```

3. Click the three-dot menu in the top right.

4. Choose export/download workflow.

5. Save the exported JSON as:

   ```text
   workflows/wazuh-alert-intake.json
   ```

6. Open the JSON file before publishing and make sure it does not contain:

   - Telegram bot token
   - AbuseIPDB API key
   - Wazuh password
   - Any real credentials


- `workflows/wazuh-alert-intake.json`
- screenshots of the workflow canvas and successful executions
