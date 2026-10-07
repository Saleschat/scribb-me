## Docs reference text in this style
API keys don't expire on their own, so it's a good idea to rotate them every few months, and right away when someone who had access leaves your team. Here's how: create a new key in **Settings** > **API keys**, swap it into every service that uses the old one, then revoke the old key. Anything still using the old key will start getting `401` errors, so keep an eye on your logs for a bit afterwards.

## UI reference strings in this style
| Role | String |
|---|---|
| dialog-title | Delete this project? |
| dialog-description | We'll delete the project and its 12 dashboards. You won't be able to get them back. |
| destructive-confirm | Delete project |
| toast | Your project's been deleted |
| field-error | We couldn't delete the project. Check your connection and try again. |
