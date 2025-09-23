This will contain hippo_auth, a well tested auth implementation using the hippo_auth backend based on better-auth.



Generate new openapi spec (requires npx):

npx @openapitools/openapi-generator-cli generate \
  -i specs/openapi.json \
  -g dart \
  -o ./api \
  --additional-properties=pubName=hippo_auth_server_api,pubPublishTo=none
