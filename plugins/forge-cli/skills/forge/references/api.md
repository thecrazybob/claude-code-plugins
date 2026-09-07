# Forge API v2

Official sources, retrieved 2026-09-07:

- [OpenAPI schema](https://forge.laravel.com/api/docs.openapi), bundled unchanged as [openapi.json](openapi.json).
- [API introduction](https://laravel.com/forge/docs/api-reference/introduction), [pagination](https://laravel.com/forge/docs/api-reference/pagination), and [rate limits](https://laravel.com/forge/docs/api-reference/rate-limiting).
- [Complete operation index](api-operations.md): every method, path, operation ID, processing mode, and permission from the snapshot.

The current API base is `https://forge.laravel.com/api`, **not `/api/v2`**. Organization-scoped routes start with `/orgs/{organization}`. The OpenAPI format version is `3.1.0`; its `info.version` is `0.0.1`. Neither is a URL prefix or the Forge CLI release version.

## Find an operation and its exact payload

Search `api-operations.md` by resource, action, or operation ID. Then extract that operation from the bundled schema instead of reading the entire schema into context. Run these commands from this skill's directory:

```bash
rg -n 'database|backup|deploy|domain' references/api-operations.md
jq '.paths["/orgs/{organization}/servers"].get' references/openapi.json

# Resolve a requestBody/response $ref by looking up its exact component name:
jq '.components.schemas.CreateBackgroundProcessRequest' references/openapi.json
```

Read path-level parameters as well as operation parameters, `requestBody`, `responses`, `security`, and `x-permissions`. Follow every relevant `$ref`, including nested request properties. Required fields, types, enums, filters, and content types vary by operation. A CLI command and an API operation with similar names need not accept the same arguments.

## Authentication and requests

Use an existing authorized token from the environment or secret manager; never print credentials or commit them. A token needs the operation's permissions. Example read-only request with an existing `FORGE_API_TOKEN`:

```bash
curl --fail-with-body --silent --show-error \
  --header "Authorization: Bearer ${FORGE_API_TOKEN}" \
  --header 'Accept: application/json' \
  'https://forge.laravel.com/api/orgs'
```

For JSON writes, use the operation's HTTP method, `Content-Type: application/json`, and `--data-binary @request.json`. Some operations require `multipart/form-data`; use the schema's fields and let `curl --form` set the boundary. Apply the same authorization requirements as CLI/SSH mutations. Standalone skill installs have no plugin guard hook, and the optional plugin hook does not cover arbitrary HTTP requests.

## Pagination, asynchronous work, and failures

- Paginated responses default to 30 items. Pass URL-encoded `page[size]` and `page[cursor]` as supported by the operation. Continue with `meta.next_cursor` until null; a single page is not the full inventory.
- The documented default is 60 requests/minute per authenticated user. Inspect `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and `X-RateLimit-Reset`; honor `Retry-After` when supplied. Keep read retries bounded (at most three), then report the failure.
- `202` and `x-processingMode: async` mean accepted, not completed. Use the returned resource ID and the corresponding status/log endpoint, bound the wait, and report pending work honestly.
- Inspect HTTP status and the documented response body. Stop on authentication/permission/validation errors (`401`, `403`, `422`) and correct the cause. Do not blindly retry writes after a timeout: inspect resource state first to avoid duplicate deployments, commands, or resources.
- Redact environment values, credentials, private keys, and other secrets from output.

## Refresh and check the snapshot

From this skill's directory, fetch into a temporary file so a failed download cannot truncate the existing schema, then regenerate and validate the index:

```bash
curl --fail --silent --show-error --location --max-time 60 \
  https://forge.laravel.com/api/docs.openapi -o references/openapi.json.new
python3 -m json.tool references/openapi.json.new > /dev/null
# Only after both commands succeed:
mv references/openapi.json.new references/openapi.json
python3 scripts/api-reference.py
python3 scripts/api-reference.py --check
```

Review the diff and update the retrieval date above. The generated index records the schema's SHA-256. If a requested feature is absent, refresh the official schema before inventing an endpoint.
