GET /.well-known/matrix/client 

Gets discovery information about the domain. The file may include additional keys, which MUST follow the Java package naming convention, e.g. com.example.myapp.property. This ensures property names are suitably namespaced for each application and reduces the risk of clashes.

Note that this endpoint is not necessarily handled by the homeserver, but by another webserver, to be used for discovering the homeserver URL.

Rate-limited:	No
Requires authentication:	No
Request

No request parameters or request body.

Responses
Status	Description
200	Server discovery information.
404	No server discovery information available.
200 response
Discovery Information
Name	Type	Description
m.homeserver	Homeserver Information	Required: Used by clients to discover homeserver information.
m.identity_server	Identity Server Information	Used by clients to discover identity server information.
Homeserver Information
Name	Type	Description
base_url	string	Required: The base URL for the homeserver for client-server connections.
Identity Server Information
Name	Type	Description
base_url	string	Required: The base URL for the identity server for client-server connections.
{
  "m.homeserver": {
    "base_url": "https://matrix.example.com"
  },
  "m.identity_server": {
    "base_url": "https://identity.example.com"
  },
  "org.example.custom.property": {
    "app_url": "https://custom.app.example.org"
  }
}
GET /_matrix/client/versions 

Gets the versions of the specification supported by the server.

Values will take the form vX.Y or rX.Y.Z in historical cases. See the Specification Versioning for more information.

The server may additionally advertise experimental features it supports through unstable_features. These features should be namespaced and may optionally include version information within their name if desired. Features listed here are not for optionally toggling parts of the Matrix specification and should only be used to advertise support for a feature which has not yet landed in the spec. For example, a feature currently undergoing the proposal process may appear here and eventually be taken off this list once the feature lands in the spec and the server deems it reasonable to do so. Servers may wish to keep advertising features here after they’ve been released into the spec to give clients a chance to upgrade appropriately. Additionally, clients should avoid using unstable features in their stable releases.

Rate-limited:	No
Requires authentication:	No
Request

No request parameters or request body.

Responses
Status	Description
200	The versions supported by the server.
200 response
Name	Type	Description
unstable_features	object	Experimental features the server supports. Features not listed here, or the lack of this property all together, indicate that a feature is not supported.
versions	[string]	Required: The supported versions.
{
  "unstable_features": {
    "org.example.my_feature": true
  },
  "versions": [
    "r0.0.1",
    "v1.1"
  ]
}
GET /_matrix/client/v1/register/m.login.registration_token/validity 

Added in v1.2

Queries the server to determine if a given registration token is still valid at the time of request. This is a point-in-time check where the token might still expire by the time it is used.

Servers should be sure to rate limit this endpoint to avoid brute force attacks.

Rate-limited:	Yes
Requires authentication:	No
Request
Request parameters
query parameters
Name	Type	Description
token	string	Required: The token to check validity of.
Responses
Status	Description
200	The check has a result.
403	The homeserver does not permit registration and thus all tokens are considered invalid.
429	This request was rate-limited.
200 response
Name	Type	Description
valid	boolean	Required: True if the token is still valid, false otherwise. This should additionally be false if the token is not a recognised token by the server.
{
  "valid": true
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "Registration is not enabled on this homeserver."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/login 

Gets the homeserver’s supported login types to authenticate users. Clients should pick one of these and supply it as the type when logging in.

Rate-limited:	Yes
Requires authentication:	No
Request

No request parameters or request body.

Responses
Status	Description
200	The login types the homeserver supports
429	This request was rate-limited.
200 response
Name	Type	Description
flows	[LoginFlow]	The homeserver’s supported login types
LoginFlow
Name	Type	Description
type	string	The login type. This is supplied as the type when logging in.
{
  "flows": [
    {
      "type": "m.login.password"
    }
  ]
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/login 

Authenticates the user, and issues an access token they can use to authorize themself in subsequent requests.

If the client does not supply a device_id, the server must auto-generate one.

The returned access token must be associated with the device_id supplied by the client or generated by the server. The server may invalidate any access token previously associated with that device. See Relationship between access tokens and devices.

Rate-limited:	Yes
Requires authentication:	No
Request
Request body
Name	Type	Description
address	string	Third party identifier for the user. Deprecated in favour of identifier.
device_id	string	ID of the client device. If this does not correspond to a known client device, a new device will be created. The given device ID must not be the same as a cross-signing key ID. The server will auto-generate a device_id if this is not specified.
identifier	User identifier	Identification information for a user
initial_device_display_name	string	A display name to assign to the newly-created device. Ignored if device_id corresponds to a known device.
medium	string	When logging in using a third party identifier, the medium of the identifier. Must be ’email’. Deprecated in favour of identifier.
password	string	Required when type is m.login.password. The user’s password.
refresh_token	boolean	If true, the client supports refresh tokens.

Added in v1.3


token	string	Required when type is m.login.token. Part of Token-based login.
type	enum	Required: The login type being used.

One of: [m.login.password, m.login.token].


user	string	The fully qualified user ID or just local part of the user ID, to log in. Deprecated in favour of identifier.
User identifier
Name	Type	Description
type	string	Required: The type of identification. See Identifier types for supported values and additional property descriptions.
Request body example
{
  "identifier": {
    "type": "m.id.user",
    "user": "cheeky_monkey"
  },
  "initial_device_display_name": "Jungle Phone",
  "password": "ilovebananas",
  "type": "m.login.password"
}

Responses
Status	Description
200	The user has been authenticated.
400	Part of the request was invalid. For example, the login type may not be recognised.
403	

The login attempt failed. This can include one of the following error codes:

M_FORBIDDEN: The provided authentication data was incorrect or the requested device ID is the same as a cross-signing key ID.
M_USER_DEACTIVATED: The user has been deactivated.

429	This request was rate-limited.
200 response
Name	Type	Description
access_token	string	Required: An access token for the account. This access token can then be used to authorize other requests.
device_id	string	Required: ID of the logged-in device. Will be the same as the corresponding parameter in the request, if one was specified.
expires_in_ms	integer	The lifetime of the access token, in milliseconds. Once the access token has expired a new access token can be obtained by using the provided refresh token. If no refresh token is provided, the client will need to re-log in to obtain a new access token. If not given, the client can assume that the access token will not expire.

Added in v1.3


home_server	string	

The server_name of the homeserver on which the account has been registered.

Deprecated. Clients should extract the server_name from user_id (by splitting at the first colon) if they require it. Note also that homeserver is not spelt this way.


refresh_token	string	A refresh token for the account. This token can be used to obtain a new access token when it expires by calling the /refresh endpoint.

Added in v1.3


user_id	string	Required: The fully-qualified Matrix ID for the account.
well_known	Discovery Information	Optional client configuration provided by the server. If present, clients SHOULD use the provided object to reconfigure themselves, optionally validating the URLs within. This object takes the same form as the one returned from .well-known autodiscovery.
Discovery Information
Name	Type	Description
m.homeserver	Homeserver Information	Required: Used by clients to discover homeserver information.
m.identity_server	Identity Server Information	Used by clients to discover identity server information.
Homeserver Information
Name	Type	Description
base_url	string	Required: The base URL for the homeserver for client-server connections.
Identity Server Information
Name	Type	Description
base_url	string	Required: The base URL for the identity server for client-server connections.
{
  "access_token": "abc123",
  "device_id": "GHTYAJCE",
  "expires_in_ms": 60000,
  "refresh_token": "def456",
  "user_id": "@cheeky_monkey:matrix.org",
  "well_known": {
    "m.homeserver": {
      "base_url": "https://example.org"
    },
    "m.identity_server": {
      "base_url": "https://id.example.org"
    }
  }
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN",
  "error": "Bad login type."
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/refresh 

Added in v1.3

Refresh an access token. Clients should use the returned access token when making subsequent API calls, and store the returned refresh token (if given) in order to refresh the new access token when necessary.

After an access token has been refreshed, a server can choose to invalidate the old access token immediately, or can choose not to, for example if the access token would expire soon anyways. Clients should not make any assumptions about the old access token still being valid, and should use the newly provided access token instead.

The old refresh token remains valid until the new access token or refresh token is used, at which point the old refresh token is revoked.

Note that this endpoint does not require authentication via an access token. Authentication is provided via the refresh token.

Application Service identity assertion is disabled for this endpoint.

Rate-limited:	Yes
Requires authentication:	No
Request
Request body
Name	Type	Description
refresh_token	string	Required: The refresh token
Request body example
{
  "refresh_token": "some_token"
}

Responses
Status	Description
200	A new access token and refresh token were generated.
401	The provided token was unknown, or has already been used.
429	This request was rate-limited.
200 response
Name	Type	Description
access_token	string	Required: The new access token to use.
expires_in_ms	integer	The lifetime of the access token, in milliseconds. If not given, the client can assume that the access token will not expire.
refresh_token	string	The new refresh token to use when the access token needs to be refreshed again. If not given, the old refresh token can be re-used.
{
  "access_token": "a_new_token",
  "expires_in_ms": 60000,
  "refresh_token": "another_new_token"
}

401 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN_TOKEN",
  "error": "Soft logged out",
  "soft_logout": true
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/logout 

Invalidates an existing access token, so that it can no longer be used for authorization. The device associated with the access token is also deleted. Device keys for the device are deleted alongside the device.

Rate-limited:	No
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	The access token used in the request was successfully invalidated.
200 response
{}
POST /_matrix/client/v3/logout/all 

Invalidates all access tokens for a user, so that they can no longer be used for authorization. This includes the access token that made this request. All devices for the user are also deleted. Device keys for the device are deleted alongside the device.

This endpoint does not use the User-Interactive Authentication API because User-Interactive Authentication is designed to protect against attacks where the someone gets hold of a single access token then takes over the account. This endpoint invalidates all access tokens for the user, including the token used in the request, and therefore the attacker is unable to take over the account in this way.

Rate-limited:	No
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	The user’s access tokens were successfully invalidated.
200 response
{}
POST /_matrix/client/v3/account/deactivate 

Deactivate the user’s account, removing all ability for the user to login again.

This API endpoint uses the User-Interactive Authentication API.

An access token should be submitted to this endpoint if the client has an active session.

The homeserver may change the flows available depending on whether a valid access token is provided.

Unlike other endpoints, this endpoint does not take an id_access_token parameter because the homeserver is expected to sign the request to the identity server instead.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request body
Name	Type	Description
auth	Authentication Data	Additional authentication information for the user-interactive authentication API.
id_server	string	The identity server to unbind all of the user’s 3PIDs from. If not provided, the homeserver MUST use the id_server that was originally use to bind each identifier. If the homeserver does not know which id_server that was, it must return an id_server_unbind_result of no-support.
Authentication Data
Name	Type	Description
session	string	The value of the session key given by the homeserver.
type	string	The authentication type that the client is attempting to complete. May be omitted if session is given, and the client is reissuing a request which it believes has been completed out-of-band (for example, via the fallback mechanism).
Request body example
{
  "auth": {
    "example_credential": "verypoorsharedsecret",
    "session": "xxxxx",
    "type": "example.type.foo"
  },
  "id_server": "example.org"
}

Responses
Status	Description
200	The account has been deactivated.
401	The homeserver requires additional authentication information.
429	This request was rate-limited.
200 response
Name	Type	Description
id_server_unbind_result	enum	Required: An indicator as to whether or not the homeserver was able to unbind the user’s 3PIDs from the identity server(s). success indicates that all identifiers have been unbound from the identity server while no-support indicates that one or more identifiers failed to unbind due to the identity server refusing the request or the homeserver being unable to determine an identity server to unbind from. This must be success if the homeserver has no identifiers to unbind for the user.

One of: [success, no-support].

{
  "id_server_unbind_result": "success"
}

401 response
Authentication response
Name	Type	Description
completed	[string]	A list of the stages the client has completed successfully
flows	[Flow information]	Required: A list of the login flows supported by the server for this API.
params	object	Contains any information that the client will need to know in order to use a given type of authentication. For each login type presented, that type may be present as a key in this dictionary. For example, the public part of an OAuth client ID could be given here.
session	string	This is a session identifier that the client must pass back to the home server, if one is provided, in subsequent attempts to authenticate in the same API call.
Flow information
Name	Type	Description
stages	[string]	Required: The login type of each of the stages required to complete this authentication flow
{
  "completed": [
    "example.type.foo"
  ],
  "flows": [
    {
      "stages": [
        "example.type.foo"
      ]
    }
  ],
  "params": {
    "example.type.baz": {
      "example_key": "foobar"
    }
  },
  "session": "xxxxxxyz"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/account/password 

Changes the password for an account on this homeserver.

This API endpoint uses the User-Interactive Authentication API to ensure the user changing the password is actually the owner of the account.

An access token should be submitted to this endpoint if the client has an active session.

The homeserver may change the flows available depending on whether a valid access token is provided. The homeserver SHOULD NOT revoke the access token provided in the request. Whether other access tokens for the user are revoked depends on the request parameters.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request body
Name	Type	Description
auth	Authentication Data	Additional authentication information for the user-interactive authentication API.
logout_devices	boolean	

Whether the user’s other access tokens, and their associated devices, should be revoked if the request succeeds. Defaults to true.

When false, the server can still take advantage of the soft logout method for the user’s remaining devices.


new_password	string	Required: The new password for the account.
Authentication Data
Name	Type	Description
session	string	The value of the session key given by the homeserver.
type	string	The authentication type that the client is attempting to complete. May be omitted if session is given, and the client is reissuing a request which it believes has been completed out-of-band (for example, via the fallback mechanism).
Request body example
{
  "auth": {
    "example_credential": "verypoorsharedsecret",
    "session": "xxxxx",
    "type": "example.type.foo"
  },
  "logout_devices": true,
  "new_password": "ihatebananas"
}

Responses
Status	Description
200	The password has been changed.
401	The homeserver requires additional authentication information.
429	This request was rate-limited.
200 response
{}

401 response
Authentication response
Name	Type	Description
completed	[string]	A list of the stages the client has completed successfully
flows	[Flow information]	Required: A list of the login flows supported by the server for this API.
params	object	Contains any information that the client will need to know in order to use a given type of authentication. For each login type presented, that type may be present as a key in this dictionary. For example, the public part of an OAuth client ID could be given here.
session	string	This is a session identifier that the client must pass back to the home server, if one is provided, in subsequent attempts to authenticate in the same API call.
Flow information
Name	Type	Description
stages	[string]	Required: The login type of each of the stages required to complete this authentication flow
{
  "completed": [
    "example.type.foo"
  ],
  "flows": [
    {
      "stages": [
        "example.type.foo"
      ]
    }
  ],
  "params": {
    "example.type.baz": {
      "example_key": "foobar"
    }
  },
  "session": "xxxxxxyz"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/account/password/email/requestToken 

The homeserver must check that the given email address is associated with an account on this homeserver. This API should be used to request validation tokens when authenticating for the /account/password endpoint.

This API’s parameters and response are identical to that of the /register/email/requestToken endpoint, except that M_THREEPID_NOT_FOUND may be returned if no account matching the given email address could be found. The server may instead send an email to the given address prompting the user to create an account. M_THREEPID_IN_USE may not be returned.

The homeserver should validate the email itself, either by sending a validation email itself or by using a service it has control over.

Rate-limited:	No
Requires authentication:	No
Request
Request body
Name	Type	Description
client_secret	string	Required: A unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters [0-9a-zA-Z.=_-]. Its length must not exceed 255 characters and it must not be empty.
email	string	Required: The email address to validate.
id_access_token	string	

An access token previously registered with the identity server. Servers can treat this as optional to distinguish between r0.5-compatible clients and this specification version.

Required if an id_server is supplied.


id_server	string	

The hostname of the identity server to communicate with. May optionally include a port. This parameter is ignored when the homeserver handles 3PID verification.

This parameter is deprecated with a plan to be removed in a future specification version for /account/password and /register requests.


next_link	string	Optional. When the validation is completed, the identity server will redirect the user to this URL. This option is ignored when submitting 3PID validation information through a POST request.
send_attempt	integer	Required: The server will only send an email if the send_attempt is a number greater than the most recent one which it has seen, scoped to that email + client_secret pair. This is to avoid repeatedly sending the same email in the case of request retries between the POSTing user and the identity server. The client should increment this value if they desire a new email (e.g. a reminder) to be sent. If they do not, the server should respond with success but not resend the email.
Request body example
{
  "client_secret": "monkeys_are_GREAT",
  "email": "alice@example.org",
  "id_server": "id.example.com",
  "next_link": "https://example.org/congratulations.html",
  "send_attempt": 1
}

Responses
Status	Description
200	An email was sent to the given address.
400	The referenced third party identifier is not recognised by the homeserver, or the request was invalid. The error code M_SERVER_NOT_TRUSTED can be returned if the server does not trust/support the identity server provided in the request.
403	The homeserver does not allow the third party identifier as a contact option.
200 response
RequestTokenResponse
Name	Type	Description
sid	string	Required: The session ID. Session IDs are opaque strings that must consist entirely of the characters [0-9a-zA-Z.=_-]. Their length must not exceed 255 characters and they must not be empty.
submit_url	string	

An optional field containing a URL where the client must submit the validation token to, with identical parameters to the Identity Service API’s POST /validate/email/submitToken endpoint (without the requirement for an access token). The homeserver must send this token to the user (if applicable), who should then be prompted to provide it to the client.

If this field is not present, the client can assume that verification will happen without the client’s involvement provided the homeserver advertises this specification version in the /versions response (ie: r0.5.0).

{
  "sid": "123abc",
  "submit_url": "https://example.org/path/to/submitToken"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_NOT_FOUND",
  "error": "Email not found"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_DENIED",
  "error": "Third party identifier is not allowed"
}
POST /_matrix/client/v3/account/password/msisdn/requestToken 

The homeserver must check that the given phone number is associated with an account on this homeserver. This API should be used to request validation tokens when authenticating for the /account/password endpoint.

This API’s parameters and response are identical to that of the /register/msisdn/requestToken endpoint, except that M_THREEPID_NOT_FOUND may be returned if no account matching the given phone number could be found. The server may instead send the SMS to the given phone number prompting the user to create an account. M_THREEPID_IN_USE may not be returned.

The homeserver should validate the phone number itself, either by sending a validation message itself or by using a service it has control over.

Rate-limited:	No
Requires authentication:	No
Request
Request body
Name	Type	Description
client_secret	string	Required: A unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters [0-9a-zA-Z.=_-]. Its length must not exceed 255 characters and it must not be empty.
country	string	Required: The two-letter uppercase ISO-3166-1 alpha-2 country code that the number in phone_number should be parsed as if it were dialled from.
id_access_token	string	

An access token previously registered with the identity server. Servers can treat this as optional to distinguish between r0.5-compatible clients and this specification version.

Required if an id_server is supplied.


id_server	string	

The hostname of the identity server to communicate with. May optionally include a port. This parameter is ignored when the homeserver handles 3PID verification.

This parameter is deprecated with a plan to be removed in a future specification version for /account/password and /register requests.


next_link	string	Optional. When the validation is completed, the identity server will redirect the user to this URL. This option is ignored when submitting 3PID validation information through a POST request.
phone_number	string	Required: The phone number to validate.
send_attempt	integer	Required: The server will only send an SMS if the send_attempt is a number greater than the most recent one which it has seen, scoped to that country + phone_number + client_secret triple. This is to avoid repeatedly sending the same SMS in the case of request retries between the POSTing user and the identity server. The client should increment this value if they desire a new SMS (e.g. a reminder) to be sent.
Request body example
{
  "client_secret": "monkeys_are_GREAT",
  "country": "GB",
  "id_server": "id.example.com",
  "next_link": "https://example.org/congratulations.html",
  "phone_number": "07700900001",
  "send_attempt": 1
}

Responses
Status	Description
200	An SMS message was sent to the given phone number.
400	The referenced third party identifier is not recognised by the homeserver, or the request was invalid. The error code M_SERVER_NOT_TRUSTED can be returned if the server does not trust/support the identity server provided in the request.
403	The homeserver does not allow the third party identifier as a contact option.
200 response
RequestTokenResponse
Name	Type	Description
sid	string	Required: The session ID. Session IDs are opaque strings that must consist entirely of the characters [0-9a-zA-Z.=_-]. Their length must not exceed 255 characters and they must not be empty.
submit_url	string	

An optional field containing a URL where the client must submit the validation token to, with identical parameters to the Identity Service API’s POST /validate/email/submitToken endpoint (without the requirement for an access token). The homeserver must send this token to the user (if applicable), who should then be prompted to provide it to the client.

If this field is not present, the client can assume that verification will happen without the client’s involvement provided the homeserver advertises this specification version in the /versions response (ie: r0.5.0).

{
  "sid": "123abc",
  "submit_url": "https://example.org/path/to/submitToken"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_NOT_FOUND",
  "error": "Phone number not found"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_DENIED",
  "error": "Third party identifier is not allowed"
}
POST /_matrix/client/v3/register 

This API endpoint uses the User-Interactive Authentication API, except in the cases where a guest account is being registered.

Register for an account on this homeserver.

There are two kinds of user account:

user accounts. These accounts may use the full API described in this specification.

guest accounts. These accounts may have limited permissions and may not be supported by all servers.

If registration is successful, this endpoint will issue an access token the client can use to authorize itself in subsequent requests.

If the client does not supply a device_id, the server must auto-generate one.

The server SHOULD register an account with a User ID based on the username provided, if any. Note that the grammar of Matrix User ID localparts is restricted, so the server MUST either map the provided username onto a user_id in a logical manner, or reject username\s which do not comply to the grammar, with M_INVALID_USERNAME.

Matrix clients MUST NOT assume that localpart of the registered user_id matches the provided username.

The returned access token must be associated with the device_id supplied by the client or generated by the server. The server may invalidate any access token previously associated with that device. See Relationship between access tokens and devices.

When registering a guest account, all parameters in the request body with the exception of initial_device_display_name MUST BE ignored by the server. The server MUST pick a device_id for the account regardless of input.

Any user ID returned by this API must conform to the grammar given in the Matrix specification.

Rate-limited:	Yes
Requires authentication:	No
Request
Request parameters
query parameters
Name	Type	Description
kind	enum	The kind of account to register. Defaults to user.

One of: [guest, user].

Request body
Name	Type	Description
auth	Authentication Data	Additional authentication information for the user-interactive authentication API. Note that this information is not used to define how the registered user should be authenticated, but is instead used to authenticate the register call itself.
device_id	string	ID of the client device. If this does not correspond to a known client device, a new device will be created. The server will auto-generate a device_id if this is not specified.
inhibit_login	boolean	If true, an access_token and device_id should not be returned from this call, therefore preventing an automatic login. Defaults to false.
initial_device_display_name	string	A display name to assign to the newly-created device. Ignored if device_id corresponds to a known device.
password	string	The desired password for the account.
refresh_token	boolean	If true, the client supports refresh tokens.

Added in v1.3


username	string	The basis for the localpart of the desired Matrix ID. If omitted, the homeserver MUST generate a Matrix ID local part.
Authentication Data
Name	Type	Description
session	string	The value of the session key given by the homeserver.
type	string	The authentication type that the client is attempting to complete. May be omitted if session is given, and the client is reissuing a request which it believes has been completed out-of-band (for example, via the fallback mechanism).
Request body example
{
  "auth": {
    "example_credential": "verypoorsharedsecret",
    "session": "xxxxx",
    "type": "example.type.foo"
  },
  "device_id": "GHTYAJCE",
  "initial_device_display_name": "Jungle Phone",
  "password": "ilovebananas",
  "username": "cheeky_monkey"
}

Responses
Status	Description
200	The account has been registered.
400	

Part of the request was invalid. This may include one of the following error codes:

M_USER_IN_USE : The desired user ID is already taken.
M_INVALID_USERNAME : The desired user ID is not a valid user name.
M_EXCLUSIVE : The desired user ID is in the exclusive namespace claimed by an application service.

These errors may be returned at any stage of the registration process, including after authentication if the requested user ID was registered whilst the client was performing authentication.

Homeservers MUST perform the relevant checks and return these codes before performing User-Interactive Authentication, although they may also return them after authentication is completed if, for example, the requested user ID was registered whilst the client was performing authentication.


401	The homeserver requires additional authentication information.
403	The homeserver does not permit registering the account. This response can be used to identify that a particular kind of account is not allowed, or that registration is generally not supported by the homeserver.
429	This request was rate-limited.
200 response
Name	Type	Description
access_token	string	An access token for the account. This access token can then be used to authorize other requests. Required if the inhibit_login option is false.
device_id	string	ID of the registered device. Will be the same as the corresponding parameter in the request, if one was specified. Required if the inhibit_login option is false.
expires_in_ms	integer	

The lifetime of the access token, in milliseconds. Once the access token has expired a new access token can be obtained by using the provided refresh token. If no refresh token is provided, the client will need to re-log in to obtain a new access token. If not given, the client can assume that the access token will not expire.

Omitted if the inhibit_login option is true.

Added in v1.3


home_server	string	

The server_name of the homeserver on which the account has been registered.

Deprecated. Clients should extract the server_name from user_id (by splitting at the first colon) if they require it. Note also that homeserver is not spelt this way.


refresh_token	string	

A refresh token for the account. This token can be used to obtain a new access token when it expires by calling the /refresh endpoint.

Omitted if the inhibit_login option is true.

Added in v1.3


user_id	string	Required:

The fully-qualified Matrix user ID (MXID) that has been registered.

Any user ID returned by this API must conform to the grammar given in the Matrix specification.

{
  "access_token": "abc123",
  "device_id": "GHTYAJCE",
  "user_id": "@cheeky_monkey:matrix.org"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_USER_IN_USE",
  "error": "Desired user ID is already taken."
}

401 response
Authentication response
Name	Type	Description
completed	[string]	A list of the stages the client has completed successfully
flows	[Flow information]	Required: A list of the login flows supported by the server for this API.
params	object	Contains any information that the client will need to know in order to use a given type of authentication. For each login type presented, that type may be present as a key in this dictionary. For example, the public part of an OAuth client ID could be given here.
session	string	This is a session identifier that the client must pass back to the home server, if one is provided, in subsequent attempts to authenticate in the same API call.
Flow information
Name	Type	Description
stages	[string]	Required: The login type of each of the stages required to complete this authentication flow
{
  "completed": [
    "example.type.foo"
  ],
  "flows": [
    {
      "stages": [
        "example.type.foo"
      ]
    }
  ],
  "params": {
    "example.type.baz": {
      "example_key": "foobar"
    }
  },
  "session": "xxxxxxyz"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "Registration is disabled"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/register/available 

Checks to see if a username is available, and valid, for the server.

The server should check to ensure that, at the time of the request, the username requested is available for use. This includes verifying that an application service has not claimed the username and that the username fits the server’s desired requirements (for example, a server could dictate that it does not permit usernames with underscores).

Matrix clients may wish to use this API prior to attempting registration, however the clients must also be aware that using this API does not normally reserve the username. This can mean that the username becomes unavailable between checking its availability and attempting to register it.

Rate-limited:	Yes
Requires authentication:	No
Request
Request parameters
query parameters
Name	Type	Description
username	string	Required: The username to check the availability of.
Responses
Status	Description
200	The username is available
400	

Part of the request was invalid or the username is not available. This may include one of the following error codes:

M_USER_IN_USE : The desired username is already taken.
M_INVALID_USERNAME : The desired username is not a valid user name.
M_EXCLUSIVE : The desired username is in the exclusive namespace claimed by an application service.

429	This request was rate-limited.
200 response
Name	Type	Description
available	boolean	A flag to indicate that the username is available. This should always be true when the server replies with 200 OK.
{
  "available": true
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_USER_IN_USE",
  "error": "Desired user ID is already taken."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/register/email/requestToken 

The homeserver must check that the given email address is not already associated with an account on this homeserver. The homeserver should validate the email itself, either by sending a validation email itself or by using a service it has control over.

Rate-limited:	No
Requires authentication:	No
Request
Request body
Name	Type	Description
client_secret	string	Required: A unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters [0-9a-zA-Z.=_-]. Its length must not exceed 255 characters and it must not be empty.
email	string	Required: The email address to validate.
id_access_token	string	

An access token previously registered with the identity server. Servers can treat this as optional to distinguish between r0.5-compatible clients and this specification version.

Required if an id_server is supplied.


id_server	string	

The hostname of the identity server to communicate with. May optionally include a port. This parameter is ignored when the homeserver handles 3PID verification.

This parameter is deprecated with a plan to be removed in a future specification version for /account/password and /register requests.


next_link	string	Optional. When the validation is completed, the identity server will redirect the user to this URL. This option is ignored when submitting 3PID validation information through a POST request.
send_attempt	integer	Required: The server will only send an email if the send_attempt is a number greater than the most recent one which it has seen, scoped to that email + client_secret pair. This is to avoid repeatedly sending the same email in the case of request retries between the POSTing user and the identity server. The client should increment this value if they desire a new email (e.g. a reminder) to be sent. If they do not, the server should respond with success but not resend the email.
Request body example
{
  "client_secret": "monkeys_are_GREAT",
  "email": "alice@example.org",
  "id_server": "id.example.com",
  "next_link": "https://example.org/congratulations.html",
  "send_attempt": 1
}

Responses
Status	Description
200	An email has been sent to the specified address. Note that this may be an email containing the validation token or it may be informing the user of an error.
400	

Part of the request was invalid. This may include one of the following error codes:

M_THREEPID_IN_USE : The email address is already registered to an account on this server. However, if the homeserver has the ability to send email, it is recommended that the server instead send an email to the user with instructions on how to reset their password. This prevents malicious parties from being able to determine if a given email address has an account on the homeserver in question.
M_SERVER_NOT_TRUSTED : The id_server parameter refers to an identity server that is not trusted by this homeserver.

403	The homeserver does not permit the address to be bound.
200 response
RequestTokenResponse
Name	Type	Description
sid	string	Required: The session ID. Session IDs are opaque strings that must consist entirely of the characters [0-9a-zA-Z.=_-]. Their length must not exceed 255 characters and they must not be empty.
submit_url	string	

An optional field containing a URL where the client must submit the validation token to, with identical parameters to the Identity Service API’s POST /validate/email/submitToken endpoint (without the requirement for an access token). The homeserver must send this token to the user (if applicable), who should then be prompted to provide it to the client.

If this field is not present, the client can assume that verification will happen without the client’s involvement provided the homeserver advertises this specification version in the /versions response (ie: r0.5.0).

{
  "sid": "123abc",
  "submit_url": "https://example.org/path/to/submitToken"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_IN_USE",
  "error": "The specified address is already in use"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_DENIED",
  "error": "Third party identifier is not allowed"
}
POST /_matrix/client/v3/register/msisdn/requestToken 

The homeserver must check that the given phone number is not already associated with an account on this homeserver. The homeserver should validate the phone number itself, either by sending a validation message itself or by using a service it has control over.

Rate-limited:	No
Requires authentication:	No
Request
Request body
Name	Type	Description
client_secret	string	Required: A unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters [0-9a-zA-Z.=_-]. Its length must not exceed 255 characters and it must not be empty.
country	string	Required: The two-letter uppercase ISO-3166-1 alpha-2 country code that the number in phone_number should be parsed as if it were dialled from.
id_access_token	string	

An access token previously registered with the identity server. Servers can treat this as optional to distinguish between r0.5-compatible clients and this specification version.

Required if an id_server is supplied.


id_server	string	

The hostname of the identity server to communicate with. May optionally include a port. This parameter is ignored when the homeserver handles 3PID verification.

This parameter is deprecated with a plan to be removed in a future specification version for /account/password and /register requests.


next_link	string	Optional. When the validation is completed, the identity server will redirect the user to this URL. This option is ignored when submitting 3PID validation information through a POST request.
phone_number	string	Required: The phone number to validate.
send_attempt	integer	Required: The server will only send an SMS if the send_attempt is a number greater than the most recent one which it has seen, scoped to that country + phone_number + client_secret triple. This is to avoid repeatedly sending the same SMS in the case of request retries between the POSTing user and the identity server. The client should increment this value if they desire a new SMS (e.g. a reminder) to be sent.
Request body example
{
  "client_secret": "monkeys_are_GREAT",
  "country": "GB",
  "id_server": "id.example.com",
  "next_link": "https://example.org/congratulations.html",
  "phone_number": "07700900001",
  "send_attempt": 1
}

Responses
Status	Description
200	An SMS message has been sent to the specified phone number. Note that this may be an SMS message containing the validation token or it may be informing the user of an error.
400	

Part of the request was invalid. This may include one of the following error codes:

M_THREEPID_IN_USE : The phone number is already registered to an account on this server. However, if the homeserver has the ability to send SMS message, it is recommended that the server instead send an SMS message to the user with instructions on how to reset their password. This prevents malicious parties from being able to determine if a given phone number has an account on the homeserver in question.
M_SERVER_NOT_TRUSTED : The id_server parameter refers to an identity server that is not trusted by this homeserver.

403	The homeserver does not permit the address to be bound.
200 response
RequestTokenResponse
Name	Type	Description
sid	string	Required: The session ID. Session IDs are opaque strings that must consist entirely of the characters [0-9a-zA-Z.=_-]. Their length must not exceed 255 characters and they must not be empty.
submit_url	string	

An optional field containing a URL where the client must submit the validation token to, with identical parameters to the Identity Service API’s POST /validate/email/submitToken endpoint (without the requirement for an access token). The homeserver must send this token to the user (if applicable), who should then be prompted to provide it to the client.

If this field is not present, the client can assume that verification will happen without the client’s involvement provided the homeserver advertises this specification version in the /versions response (ie: r0.5.0).

{
  "sid": "123abc",
  "submit_url": "https://example.org/path/to/submitToken"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_IN_USE",
  "error": "The specified address is already in use"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_DENIED",
  "error": "Third party identifier is not allowed"
}
GET /_matrix/client/v3/account/3pid 

Gets a list of the third party identifiers that the homeserver has associated with the user’s account.

This is not the same as the list of third party identifiers bound to the user’s Matrix ID in identity servers.

Identifiers in this list may be used by the homeserver as, for example, identifiers that it will accept to reset the user’s account password.

Rate-limited:	No
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	The lookup was successful.
200 response
Name	Type	Description
threepids	[Third party identifier]	
Third party identifier
Name	Type	Description
added_at	integer	Required: The timestamp, in milliseconds, when the homeserver associated the third party identifier with the user.
address	string	Required: The third party identifier address.
medium	enum	Required: The medium of the third party identifier.

One of: [email, msisdn].


validated_at	integer	Required: The timestamp, in milliseconds, when the identifier was validated by the identity server.
{
  "threepids": [
    {
      "added_at": 1535336848756,
      "address": "monkey@banana.island",
      "medium": "email",
      "validated_at": 1535176800000
    }
  ]
}
POST /_matrix/client/v3/account/3pid 
This API is deprecated and will be removed from a future release.

Adds contact information to the user’s account.

This endpoint is deprecated in favour of the more specific /3pid/add and /3pid/bind endpoints.

Note: Previously this endpoint supported a bind parameter. This parameter has been removed, making this endpoint behave as though it was false. This results in this endpoint being an equivalent to /3pid/bind rather than dual-purpose.

Rate-limited:	No
Requires authentication:	Yes
Request
Request body
Name	Type	Description
three_pid_creds	ThreePidCredentials	Required: The third party credentials to associate with the account.
ThreePidCredentials
Name	Type	Description
client_secret	string	Required: The client secret used in the session with the identity server.
id_access_token	string	Required: An access token previously registered with the identity server. Servers can treat this as optional to distinguish between r0.5-compatible clients and this specification version.
id_server	string	Required: The identity server to use.
sid	string	Required: The session identifier given by the identity server.
Request body example
{
  "three_pid_creds": {
    "client_secret": "d0nt-T3ll",
    "id_access_token": "abc123_OpaqueString",
    "id_server": "matrix.org",
    "sid": "abc123987"
  }
}

Responses
Status	Description
200	The addition was successful.
403	The credentials could not be verified with the identity server.
200 response
Name	Type	Description
submit_url	string	

An optional field containing a URL where the client must submit the validation token to, with identical parameters to the Identity Service API’s POST /validate/email/submitToken endpoint (without the requirement for an access token). The homeserver must send this token to the user (if applicable), who should then be prompted to provide it to the client.

If this field is not present, the client can assume that verification will happen without the client’s involvement provided the homeserver advertises this specification version in the /versions response (ie: r0.5.0).

{
  "submit_url": "https://example.org/path/to/submitToken"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_AUTH_FAILED",
  "error": "The third party credentials could not be verified by the identity server."
}
POST /_matrix/client/v3/account/3pid/add 

This API endpoint uses the User-Interactive Authentication API.

Adds contact information to the user’s account. Homeservers should use 3PIDs added through this endpoint for password resets instead of relying on the identity server.

Homeservers should prevent the caller from adding a 3PID to their account if it has already been added to another user’s account on the homeserver.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request body
Name	Type	Description
auth	Authentication Data	Additional authentication information for the user-interactive authentication API.
client_secret	string	Required: The client secret used in the session with the homeserver.
sid	string	Required: The session identifier given by the homeserver.
Authentication Data
Name	Type	Description
session	string	The value of the session key given by the homeserver.
type	string	The authentication type that the client is attempting to complete. May be omitted if session is given, and the client is reissuing a request which it believes has been completed out-of-band (for example, via the fallback mechanism).
Request body example
{
  "auth": {
    "example_credential": "verypoorsharedsecret",
    "session": "xxxxx",
    "type": "example.type.foo"
  },
  "client_secret": "d0nt-T3ll",
  "sid": "abc123987"
}

Responses
Status	Description
200	The addition was successful.
401	The homeserver requires additional authentication information.
429	This request was rate-limited.
200 response
{}

401 response
Authentication response
Name	Type	Description
completed	[string]	A list of the stages the client has completed successfully
flows	[Flow information]	Required: A list of the login flows supported by the server for this API.
params	object	Contains any information that the client will need to know in order to use a given type of authentication. For each login type presented, that type may be present as a key in this dictionary. For example, the public part of an OAuth client ID could be given here.
session	string	This is a session identifier that the client must pass back to the home server, if one is provided, in subsequent attempts to authenticate in the same API call.
Flow information
Name	Type	Description
stages	[string]	Required: The login type of each of the stages required to complete this authentication flow
{
  "completed": [
    "example.type.foo"
  ],
  "flows": [
    {
      "stages": [
        "example.type.foo"
      ]
    }
  ],
  "params": {
    "example.type.baz": {
      "example_key": "foobar"
    }
  },
  "session": "xxxxxxyz"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/account/3pid/bind 

Binds a 3PID to the user’s account through the specified identity server.

Homeservers should not prevent this request from succeeding if another user has bound the 3PID. Homeservers should simply proxy any errors received by the identity server to the caller.

Homeservers should track successful binds so they can be unbound later.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request body
Name	Type	Description
client_secret	string	Required: The client secret used in the session with the identity server.
id_access_token	string	Required: An access token previously registered with the identity server.
id_server	string	Required: The identity server to use.
sid	string	Required: The session identifier given by the identity server.
Request body example
{
  "client_secret": "d0nt-T3ll",
  "id_access_token": "abc123_OpaqueString",
  "id_server": "example.org",
  "sid": "abc123987"
}

Responses
Status	Description
200	The addition was successful.
429	This request was rate-limited.
200 response
{}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/account/3pid/delete 

Removes a third party identifier from the user’s account. This might not cause an unbind of the identifier from the identity server.

Unlike other endpoints, this endpoint does not take an id_access_token parameter because the homeserver is expected to sign the request to the identity server instead.

Rate-limited:	No
Requires authentication:	Yes
Request
Request body
Name	Type	Description
address	string	Required: The third party address being removed.
id_server	string	The identity server to unbind from. If not provided, the homeserver MUST use the id_server the identifier was added through. If the homeserver does not know the original id_server, it MUST return a id_server_unbind_result of no-support.
medium	enum	Required: The medium of the third party identifier being removed.

One of: [email, msisdn].

Request body example
{
  "address": "example@example.org",
  "id_server": "example.org",
  "medium": "email"
}

Responses
Status	Description
200	The homeserver has disassociated the third party identifier from the user.
200 response
Name	Type	Description
id_server_unbind_result	enum	Required: An indicator as to whether or not the homeserver was able to unbind the 3PID from the identity server. success indicates that the identity server has unbound the identifier whereas no-support indicates that the identity server refuses to support the request or the homeserver was not able to determine an identity server to unbind from.

One of: [no-support, success].

{
  "id_server_unbind_result": "success"
}
POST /_matrix/client/v3/account/3pid/email/requestToken 

The homeserver must check that the given email address is not already associated with an account on this homeserver. This API should be used to request validation tokens when adding an email address to an account. This API’s parameters and response are identical to that of the /register/email/requestToken endpoint. The homeserver should validate the email itself, either by sending a validation email itself or by using a service it has control over.

Rate-limited:	No
Requires authentication:	No
Request
Request body
Name	Type	Description
client_secret	string	Required: A unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters [0-9a-zA-Z.=_-]. Its length must not exceed 255 characters and it must not be empty.
email	string	Required: The email address to validate.
id_access_token	string	

An access token previously registered with the identity server. Servers can treat this as optional to distinguish between r0.5-compatible clients and this specification version.

Required if an id_server is supplied.


id_server	string	

The hostname of the identity server to communicate with. May optionally include a port. This parameter is ignored when the homeserver handles 3PID verification.

This parameter is deprecated with a plan to be removed in a future specification version for /account/password and /register requests.


next_link	string	Optional. When the validation is completed, the identity server will redirect the user to this URL. This option is ignored when submitting 3PID validation information through a POST request.
send_attempt	integer	Required: The server will only send an email if the send_attempt is a number greater than the most recent one which it has seen, scoped to that email + client_secret pair. This is to avoid repeatedly sending the same email in the case of request retries between the POSTing user and the identity server. The client should increment this value if they desire a new email (e.g. a reminder) to be sent. If they do not, the server should respond with success but not resend the email.
Request body example
{
  "client_secret": "monkeys_are_GREAT",
  "email": "alice@example.org",
  "id_server": "id.example.com",
  "next_link": "https://example.org/congratulations.html",
  "send_attempt": 1
}

Responses
Status	Description
200	An email was sent to the given address. Note that this may be an email containing the validation token or it may be informing the user of an error.
400	The third party identifier is already in use on the homeserver, or the request was invalid. The error code M_SERVER_NOT_TRUSTED can be returned if the server does not trust/support the identity server provided in the request.
403	The homeserver does not allow the third party identifier as a contact option.
200 response
RequestTokenResponse
Name	Type	Description
sid	string	Required: The session ID. Session IDs are opaque strings that must consist entirely of the characters [0-9a-zA-Z.=_-]. Their length must not exceed 255 characters and they must not be empty.
submit_url	string	

An optional field containing a URL where the client must submit the validation token to, with identical parameters to the Identity Service API’s POST /validate/email/submitToken endpoint (without the requirement for an access token). The homeserver must send this token to the user (if applicable), who should then be prompted to provide it to the client.

If this field is not present, the client can assume that verification will happen without the client’s involvement provided the homeserver advertises this specification version in the /versions response (ie: r0.5.0).

{
  "sid": "123abc",
  "submit_url": "https://example.org/path/to/submitToken"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_IN_USE",
  "error": "Third party identifier already in use"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_DENIED",
  "error": "Third party identifier is not allowed"
}
POST /_matrix/client/v3/account/3pid/msisdn/requestToken 

The homeserver must check that the given phone number is not already associated with an account on this homeserver. This API should be used to request validation tokens when adding a phone number to an account. This API’s parameters and response are identical to that of the /register/msisdn/requestToken endpoint. The homeserver should validate the phone number itself, either by sending a validation message itself or by using a service it has control over.

Rate-limited:	No
Requires authentication:	No
Request
Request body
Name	Type	Description
client_secret	string	Required: A unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters [0-9a-zA-Z.=_-]. Its length must not exceed 255 characters and it must not be empty.
country	string	Required: The two-letter uppercase ISO-3166-1 alpha-2 country code that the number in phone_number should be parsed as if it were dialled from.
id_access_token	string	

An access token previously registered with the identity server. Servers can treat this as optional to distinguish between r0.5-compatible clients and this specification version.

Required if an id_server is supplied.


id_server	string	

The hostname of the identity server to communicate with. May optionally include a port. This parameter is ignored when the homeserver handles 3PID verification.

This parameter is deprecated with a plan to be removed in a future specification version for /account/password and /register requests.


next_link	string	Optional. When the validation is completed, the identity server will redirect the user to this URL. This option is ignored when submitting 3PID validation information through a POST request.
phone_number	string	Required: The phone number to validate.
send_attempt	integer	Required: The server will only send an SMS if the send_attempt is a number greater than the most recent one which it has seen, scoped to that country + phone_number + client_secret triple. This is to avoid repeatedly sending the same SMS in the case of request retries between the POSTing user and the identity server. The client should increment this value if they desire a new SMS (e.g. a reminder) to be sent.
Request body example
{
  "client_secret": "monkeys_are_GREAT",
  "country": "GB",
  "id_server": "id.example.com",
  "next_link": "https://example.org/congratulations.html",
  "phone_number": "07700900001",
  "send_attempt": 1
}

Responses
Status	Description
200	An SMS message was sent to the given phone number.
400	The third party identifier is already in use on the homeserver, or the request was invalid. The error code M_SERVER_NOT_TRUSTED can be returned if the server does not trust/support the identity server provided in the request.
403	The homeserver does not allow the third party identifier as a contact option.
200 response
RequestTokenResponse
Name	Type	Description
sid	string	Required: The session ID. Session IDs are opaque strings that must consist entirely of the characters [0-9a-zA-Z.=_-]. Their length must not exceed 255 characters and they must not be empty.
submit_url	string	

An optional field containing a URL where the client must submit the validation token to, with identical parameters to the Identity Service API’s POST /validate/email/submitToken endpoint (without the requirement for an access token). The homeserver must send this token to the user (if applicable), who should then be prompted to provide it to the client.

If this field is not present, the client can assume that verification will happen without the client’s involvement provided the homeserver advertises this specification version in the /versions response (ie: r0.5.0).

{
  "sid": "123abc",
  "submit_url": "https://example.org/path/to/submitToken"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_IN_USE",
  "error": "Third party identifier already in use"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_THREEPID_DENIED",
  "error": "Third party identifier is not allowed"
}
POST /_matrix/client/v3/account/3pid/unbind 

Removes a user’s third party identifier from the provided identity server without removing it from the homeserver.

Unlike other endpoints, this endpoint does not take an id_access_token parameter because the homeserver is expected to sign the request to the identity server instead.

Rate-limited:	No
Requires authentication:	Yes
Request
Request body
Name	Type	Description
address	string	Required: The third party address being removed.
id_server	string	The identity server to unbind from. If not provided, the homeserver MUST use the id_server the identifier was added through. If the homeserver does not know the original id_server, it MUST return a id_server_unbind_result of no-support.
medium	enum	Required: The medium of the third party identifier being removed.

One of: [email, msisdn].

Request body example
{
  "address": "example@example.org",
  "id_server": "example.org",
  "medium": "email"
}

Responses
Status	Description
200	The identity server has disassociated the third party identifier from the user.
200 response
Name	Type	Description
id_server_unbind_result	enum	Required: An indicator as to whether or not the identity server was able to unbind the 3PID. success indicates that the identity server has unbound the identifier whereas no-support indicates that the identity server refuses to support the request or the homeserver was not able to determine an identity server to unbind from.

One of: [no-support, success].

{
  "id_server_unbind_result": "success"
}
GET /_matrix/client/v3/account/whoami 

Gets information about the owner of a given access token.

Note that, as with the rest of the Client-Server API, Application Services may masquerade as users within their namespace by giving a user_id query parameter. In this situation, the server should verify that the given user_id is registered by the appservice, and return it in the response body.

Rate-limited:	Yes
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	The token belongs to a known user.
401	The token is not recognised
403	The appservice cannot masquerade as the user or has not registered them.
429	This request was rate-limited.
200 response
Name	Type	Description
device_id	string	Device ID associated with the access token. If no device is associated with the access token (such as in the case of application services) then this field can be omitted. Otherwise this is required.

Added in v1.1


is_guest	boolean	When true, the user is a Guest User. When not present or false, the user is presumed to be a non-guest user.

Added in v1.2


user_id	string	Required: The user ID that owns the access token.
{
  "device_id": "ABC1234",
  "user_id": "@joe:example.org"
}

401 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN_TOKEN",
  "error": "Unrecognised access token."
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "Application service has not registered this user."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/capabilities 

Gets information about the server’s supported feature set and other relevant capabilities.

Rate-limited:	Yes
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	The capabilities of the server.
429	This request was rate-limited.
200 response
Name	Type	Description
capabilities	Capabilities	Required: The custom capabilities the server supports, using the Java package naming convention.
Capabilities
Name	Type	Description
m.change_password	ChangePasswordCapability	Capability to indicate if the user can change their password.
m.room_versions	RoomVersionsCapability	The room versions the server supports.
ChangePasswordCapability
Name	Type	Description
enabled	boolean	Required: True if the user can change their password, false otherwise.
RoomVersionsCapability
Name	Type	Description
available	{string: RoomVersionStability}	Required: A detailed description of the room versions the server supports.
default	string	Required: The default room version the server is using for new rooms.
{
  "capabilities": {
    "com.example.custom.ratelimit": {
      "max_requests_per_hour": 600
    },
    "m.change_password": {
      "enabled": false
    },
    "m.room_versions": {
      "available": {
        "1": "stable",
        "2": "stable",
        "3": "unstable",
        "test-version": "unstable"
      },
      "default": "1"
    }
  }
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/user/{userId}/filter 

Uploads a new filter definition to the homeserver. Returns a filter ID that may be used in future requests to restrict which events are returned to the client.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
userId	string	Required: The id of the user uploading the filter. The access token must be authorized to make requests for this user id.
Request body
Filter
Name	Type	Description
account_data	EventFilter	The user account data that isn’t associated with rooms to include.
event_fields	[string]	List of event fields to include. If this list is absent then all fields are included. The entries may include ‘.’ characters to indicate sub-fields. So [‘content.body’] will include the ‘body’ field of the ‘content’ object. A literal ‘.’ character in a field name may be escaped using a ‘\’. A server may include more fields than were requested.
event_format	enum	The format to use for events. ‘client’ will return the events in a format suitable for clients. ‘federation’ will return the raw event as received over federation. The default is ‘client’.

One of: [client, federation].


presence	EventFilter	The presence updates to include.
room	RoomFilter	Filters to be applied to room data.
EventFilter
Name	Type	Description
limit	integer	The maximum number of events to return.
not_senders	[string]	A list of sender IDs to exclude. If this list is absent then no senders are excluded. A matching sender will be excluded even if it is listed in the 'senders' filter.
not_types	[string]	A list of event types to exclude. If this list is absent then no event types are excluded. A matching type will be excluded even if it is listed in the 'types' filter. A ‘*’ can be used as a wildcard to match any sequence of characters.
senders	[string]	A list of senders IDs to include. If this list is absent then all senders are included.
types	[string]	A list of event types to include. If this list is absent then all event types are included. A '*' can be used as a wildcard to match any sequence of characters.
RoomFilter
Name	Type	Description
account_data	RoomEventFilter	The per user account data to include for rooms.
ephemeral	RoomEventFilter	The ephemeral events to include for rooms. These are the events that appear in the ephemeral property in the /sync response.
include_leave	boolean	Include rooms that the user has left in the sync, default false
not_rooms	[string]	A list of room IDs to exclude. If this list is absent then no rooms are excluded. A matching room will be excluded even if it is listed in the 'rooms' filter. This filter is applied before the filters in ephemeral, state, timeline or account_data
rooms	[string]	A list of room IDs to include. If this list is absent then all rooms are included. This filter is applied before the filters in ephemeral, state, timeline or account_data
state	StateFilter	The state events to include for rooms.
timeline	RoomEventFilter	The message and state update events to include for rooms.
RoomEventFilter
Name	Type	Description
contains_url	boolean	If true, includes only events with a url key in their content. If false, excludes those events. If omitted, url key is not considered for filtering.
include_redundant_members	boolean	If true, sends all membership events for all events, even if they have already been sent to the client. Does not apply unless lazy_load_members is true. See Lazy-loading room members for more information. Defaults to false.
lazy_load_members	boolean	If true, enables lazy-loading of membership events. See Lazy-loading room members for more information. Defaults to false.
limit	integer	The maximum number of events to return.
not_rooms	[string]	A list of room IDs to exclude. If this list is absent then no rooms are excluded. A matching room will be excluded even if it is listed in the 'rooms' filter.
not_senders	[string]	A list of sender IDs to exclude. If this list is absent then no senders are excluded. A matching sender will be excluded even if it is listed in the 'senders' filter.
not_types	[string]	A list of event types to exclude. If this list is absent then no event types are excluded. A matching type will be excluded even if it is listed in the 'types' filter. A ‘*’ can be used as a wildcard to match any sequence of characters.
rooms	[string]	A list of room IDs to include. If this list is absent then all rooms are included.
senders	[string]	A list of senders IDs to include. If this list is absent then all senders are included.
types	[string]	A list of event types to include. If this list is absent then all event types are included. A '*' can be used as a wildcard to match any sequence of characters.
unread_thread_notifications	boolean	If true, enables per-thread notification counts. Only applies to the /sync endpoint. Defaults to false.

Added in v1.4

StateFilter
Name	Type	Description
contains_url	boolean	If true, includes only events with a url key in their content. If false, excludes those events. If omitted, url key is not considered for filtering.
include_redundant_members	boolean	If true, sends all membership events for all events, even if they have already been sent to the client. Does not apply unless lazy_load_members is true. See Lazy-loading room members for more information. Defaults to false.
lazy_load_members	boolean	If true, enables lazy-loading of membership events. See Lazy-loading room members for more information. Defaults to false.
limit	integer	The maximum number of events to return.
not_rooms	[string]	A list of room IDs to exclude. If this list is absent then no rooms are excluded. A matching room will be excluded even if it is listed in the 'rooms' filter.
not_senders	[string]	A list of sender IDs to exclude. If this list is absent then no senders are excluded. A matching sender will be excluded even if it is listed in the 'senders' filter.
not_types	[string]	A list of event types to exclude. If this list is absent then no event types are excluded. A matching type will be excluded even if it is listed in the 'types' filter. A ‘*’ can be used as a wildcard to match any sequence of characters.
rooms	[string]	A list of room IDs to include. If this list is absent then all rooms are included.
senders	[string]	A list of senders IDs to include. If this list is absent then all senders are included.
types	[string]	A list of event types to include. If this list is absent then all event types are included. A '*' can be used as a wildcard to match any sequence of characters.
unread_thread_notifications	boolean	If true, enables per-thread notification counts. Only applies to the /sync endpoint. Defaults to false.

Added in v1.4

Request body example
{
  "event_fields": [
    "type",
    "content",
    "sender"
  ],
  "event_format": "client",
  "presence": {
    "not_senders": [
      "@alice:example.com"
    ],
    "types": [
      "m.presence"
    ]
  },
  "room": {
    "ephemeral": {
      "not_rooms": [
        "!726s6s6q:example.com"
      ],
      "not_senders": [
        "@spam:example.com"
      ],
      "types": [
        "m.receipt",
        "m.typing"
      ]
    },
    "state": {
      "not_rooms": [
        "!726s6s6q:example.com"
      ],
      "types": [
        "m.room.*"
      ]
    },
    "timeline": {
      "limit": 10,
      "not_rooms": [
        "!726s6s6q:example.com"
      ],
      "not_senders": [
        "@spam:example.com"
      ],
      "types": [
        "m.room.message"
      ]
    }
  }
}

Responses
Status	Description
200	The filter was created.
200 response
Name	Type	Description
filter_id	string	Required: The ID of the filter that was created. Cannot start with a { as this character is used to determine if the filter provided is inline JSON or a previously declared filter by homeservers on some APIs.
{
  "filter_id": "66696p746572"
}
GET /_matrix/client/v3/user/{userId}/filter/{filterId} 

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
filterId	string	Required: The filter ID to download.
userId	string	Required: The user ID to download a filter for.
Responses
Status	Description
200	The filter definition.
404	Unknown filter.
200 response
Filter
Name	Type	Description
account_data	EventFilter	The user account data that isn’t associated with rooms to include.
event_fields	[string]	List of event fields to include. If this list is absent then all fields are included. The entries may include ‘.’ characters to indicate sub-fields. So [‘content.body’] will include the ‘body’ field of the ‘content’ object. A literal ‘.’ character in a field name may be escaped using a ‘\’. A server may include more fields than were requested.
event_format	enum	The format to use for events. ‘client’ will return the events in a format suitable for clients. ‘federation’ will return the raw event as received over federation. The default is ‘client’.

One of: [client, federation].


presence	EventFilter	The presence updates to include.
room	RoomFilter	Filters to be applied to room data.
EventFilter
Name	Type	Description
limit	integer	The maximum number of events to return.
not_senders	[string]	A list of sender IDs to exclude. If this list is absent then no senders are excluded. A matching sender will be excluded even if it is listed in the 'senders' filter.
not_types	[string]	A list of event types to exclude. If this list is absent then no event types are excluded. A matching type will be excluded even if it is listed in the 'types' filter. A ‘*’ can be used as a wildcard to match any sequence of characters.
senders	[string]	A list of senders IDs to include. If this list is absent then all senders are included.
types	[string]	A list of event types to include. If this list is absent then all event types are included. A '*' can be used as a wildcard to match any sequence of characters.
RoomFilter
Name	Type	Description
account_data	RoomEventFilter	The per user account data to include for rooms.
ephemeral	RoomEventFilter	The ephemeral events to include for rooms. These are the events that appear in the ephemeral property in the /sync response.
include_leave	boolean	Include rooms that the user has left in the sync, default false
not_rooms	[string]	A list of room IDs to exclude. If this list is absent then no rooms are excluded. A matching room will be excluded even if it is listed in the 'rooms' filter. This filter is applied before the filters in ephemeral, state, timeline or account_data
rooms	[string]	A list of room IDs to include. If this list is absent then all rooms are included. This filter is applied before the filters in ephemeral, state, timeline or account_data
state	StateFilter	The state events to include for rooms.
timeline	RoomEventFilter	The message and state update events to include for rooms.
RoomEventFilter
Name	Type	Description
contains_url	boolean	If true, includes only events with a url key in their content. If false, excludes those events. If omitted, url key is not considered for filtering.
include_redundant_members	boolean	If true, sends all membership events for all events, even if they have already been sent to the client. Does not apply unless lazy_load_members is true. See Lazy-loading room members for more information. Defaults to false.
lazy_load_members	boolean	If true, enables lazy-loading of membership events. See Lazy-loading room members for more information. Defaults to false.
limit	integer	The maximum number of events to return.
not_rooms	[string]	A list of room IDs to exclude. If this list is absent then no rooms are excluded. A matching room will be excluded even if it is listed in the 'rooms' filter.
not_senders	[string]	A list of sender IDs to exclude. If this list is absent then no senders are excluded. A matching sender will be excluded even if it is listed in the 'senders' filter.
not_types	[string]	A list of event types to exclude. If this list is absent then no event types are excluded. A matching type will be excluded even if it is listed in the 'types' filter. A ‘*’ can be used as a wildcard to match any sequence of characters.
rooms	[string]	A list of room IDs to include. If this list is absent then all rooms are included.
senders	[string]	A list of senders IDs to include. If this list is absent then all senders are included.
types	[string]	A list of event types to include. If this list is absent then all event types are included. A '*' can be used as a wildcard to match any sequence of characters.
unread_thread_notifications	boolean	If true, enables per-thread notification counts. Only applies to the /sync endpoint. Defaults to false.

Added in v1.4

StateFilter
Name	Type	Description
contains_url	boolean	If true, includes only events with a url key in their content. If false, excludes those events. If omitted, url key is not considered for filtering.
include_redundant_members	boolean	If true, sends all membership events for all events, even if they have already been sent to the client. Does not apply unless lazy_load_members is true. See Lazy-loading room members for more information. Defaults to false.
lazy_load_members	boolean	If true, enables lazy-loading of membership events. See Lazy-loading room members for more information. Defaults to false.
limit	integer	The maximum number of events to return.
not_rooms	[string]	A list of room IDs to exclude. If this list is absent then no rooms are excluded. A matching room will be excluded even if it is listed in the 'rooms' filter.
not_senders	[string]	A list of sender IDs to exclude. If this list is absent then no senders are excluded. A matching sender will be excluded even if it is listed in the 'senders' filter.
not_types	[string]	A list of event types to exclude. If this list is absent then no event types are excluded. A matching type will be excluded even if it is listed in the 'types' filter. A ‘*’ can be used as a wildcard to match any sequence of characters.
rooms	[string]	A list of room IDs to include. If this list is absent then all rooms are included.
senders	[string]	A list of senders IDs to include. If this list is absent then all senders are included.
types	[string]	A list of event types to include. If this list is absent then all event types are included. A '*' can be used as a wildcard to match any sequence of characters.
unread_thread_notifications	boolean	If true, enables per-thread notification counts. Only applies to the /sync endpoint. Defaults to false.

Added in v1.4

{
  "event_fields": [
    "type",
    "content",
    "sender"
  ],
  "event_format": "client",
  "presence": {
    "not_senders": [
      "@alice:example.com"
    ],
    "types": [
      "m.presence"
    ]
  },
  "room": {
    "ephemeral": {
      "not_rooms": [
        "!726s6s6q:example.com"
      ],
      "not_senders": [
        "@spam:example.com"
      ],
      "types": [
        "m.receipt",
        "m.typing"
      ]
    },
    "state": {
      "not_rooms": [
        "!726s6s6q:example.com"
      ],
      "types": [
        "m.room.*"
      ]
    },
    "timeline": {
      "limit": 10,
      "not_rooms": [
        "!726s6s6q:example.com"
      ],
      "not_senders": [
        "@spam:example.com"
      ],
      "types": [
        "m.room.message"
      ]
    }
  }
}
GET /_matrix/client/v3/sync 

Synchronise the client’s state with the latest state on the server. Clients use this API when they first log in to get an initial snapshot of the state on the server, and then continue to call this API to get incremental deltas to the state, and to receive new messages.

Note: This endpoint supports lazy-loading. See Filtering for more information. Lazy-loading members is only supported on a StateFilter for this endpoint. When lazy-loading is enabled, servers MUST include the syncing user’s own membership event when they join a room, or when the full state of rooms is requested, to aid discovering the user’s avatar & displayname.

Further, like other members, the user’s own membership event is eligible for being considered redundant by the server. When a sync is limited, the server MUST return membership events for events in the gap (between since and the start of the returned timeline), regardless as to whether or not they are redundant. This ensures that joins/leaves and profile changes which occur during the gap are not lost.

Note that the default behaviour of state is to include all membership events, alongside other state, when lazy-loading is not enabled.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
filter	string	

The ID of a filter created using the filter API or a filter JSON object encoded as a string. The server will detect whether it is an ID or a JSON object by whether the first character is a "{" open brace. Passing the JSON inline is best suited to one off requests. Creating a filter using the filter API is recommended for clients that reuse the same filter multiple times, for example in long poll requests.

See Filtering for more information.


full_state	boolean	

Controls whether to include the full state for all rooms the user is a member of.

If this is set to true, then all state events will be returned, even if since is non-empty. The timeline will still be limited by the since parameter. In this case, the timeout parameter will be ignored and the query will return immediately, possibly with an empty timeline.

If false, and since is non-empty, only state which has changed since the point indicated by since will be returned.

By default, this is false.


set_presence	enum	Controls whether the client is automatically marked as online by polling this API. If this parameter is omitted then the client is automatically marked as online when it uses this API. Otherwise if the parameter is set to “offline” then the client is not marked as being online when it uses this API. When set to “unavailable”, the client is marked as being idle.

One of: [offline, online, unavailable].


since	string	A point in time to continue a sync from. This should be the next_batch token returned by an earlier call to this endpoint.
timeout	integer	

The maximum time to wait, in milliseconds, before returning this request. If no events (or other data) become available before this time elapses, the server will return a response with empty fields.

By default, this is 0, so the server will return immediately even if the response is empty.

Responses
Status	Description
200	The initial snapshot or delta for the client to use to update their state.
200 response
Name	Type	Description
account_data	Account Data	The global private data created by this user.
device_lists	DeviceLists	Information on end-to-end device updates, as specified in End-to-end encryption.
device_one_time_keys_count	One-time keys count	Information on end-to-end encryption keys, as specified in End-to-end encryption.
next_batch	string	Required: The batch token to supply in the since param of the next /sync request.
presence	Presence	The updates to the presence status of other users.
rooms	Rooms	Updates to rooms.
to_device	ToDevice	Information on the send-to-device messages for the client device, as defined in Send-to-Device messaging.
Account Data
Name	Type	Description
events	[Event]	List of events.
Event
Name	Type	Description
content	object	Required: The fields in this object will vary depending on the type of event. When interacting with the REST API, this is the HTTP body.
type	string	Required: The type of event. This SHOULD be namespaced similar to Java package naming conventions e.g. ‘com.example.subdomain.event.type’
Presence
Name	Type	Description
events	[Event]	List of events.
Rooms
Name	Type	Description
invite	{string: Invited Room}	The rooms that the user has been invited to, mapped as room ID to room information.
join	{string: Joined Room}	The rooms that the user has joined, mapped as room ID to room information.
knock	{string: Knocked Room}	The rooms that the user has knocked upon, mapped as room ID to room information.
leave	{string: Left Room}	The rooms that the user has left or been banned from, mapped as room ID to room information.
Invited Room
Name	Type	Description
invite_state	InviteState	The stripped state of a room that the user has been invited to.
InviteState
Name	Type	Description
events	[StrippedStateEvent]	The stripped state events that form the invite state.
StrippedStateEvent
Name	Type	Description
content	EventContent	Required: The content for the event.
sender	string	Required: The sender for the event.
state_key	string	Required: The state_key for the event.
type	string	Required: The type for the event.
Joined Room
Name	Type	Description
account_data	Account Data	The private data that this user has attached to this room.
ephemeral	Ephemeral	The new ephemeral events in the room (events that aren’t recorded in the timeline or state of the room). In this version of the spec, these are typing notification and read receipt events.
state	State	

Updates to the state, between the time indicated by the since parameter, and the start of the timeline (or all state up to the start of the timeline, if since is not given, or full_state is true).

N.B. state updates for m.room.member events will be incomplete if lazy_load_members is enabled in the /sync filter, and only return the member events required to display the senders of the timeline events in this response.


summary	RoomSummary	Information about the room which clients may need to correctly render it to users.
timeline	Timeline	The timeline of messages and state changes in the room.
unread_notifications	Unread Notification Counts	

Counts of unread notifications for this room. See the Receiving notifications section for more information on how these are calculated.

If unread_thread_notifications was specified as true on the RoomEventFilter, these counts will only be for the main timeline rather than all events in the room. See the threading module for more information.



Changed in v1.4: Updated to reflect behaviour of having unread_thread_notifications as true in the RoomEventFilter for /sync.
unread_thread_notifications	{string: ThreadNotificationCounts}	

If unread_thread_notifications was specified as true on the RoomEventFilter, the notification counts for each thread in this room. The object is keyed by thread root ID, with values matching unread_notifications.

If a thread does not have any notifications it can be omitted from this object. If no threads have notification counts, this whole object can be omitted.

Added in v1.4

Ephemeral
Name	Type	Description
events	[Event]	List of events.
State
Name	Type	Description
events	[ClientEventWithoutRoomID]	List of events.
ClientEventWithoutRoomID
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEventWithoutRoomID	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
RoomSummary
Name	Type	Description
m.heroes	[string]	

The users which can be used to generate a room name if the room does not have one. Required if the room’s m.room.name or m.room.canonical_alias state events are unset or empty.

This should be the first 5 members of the room, ordered by stream ordering, which are joined or invited. The list must never include the client’s own user ID. When no joined or invited members are available, this should consist of the banned and left users. More than 5 members may be provided, however less than 5 should only be provided when there are less than 5 members to represent.

When lazy-loading room members is enabled, the membership events for the heroes MUST be included in the state, unless they are redundant. When the list of users changes, the server notifies the client by sending a fresh list of heroes. If there are no changes since the last sync, this field may be omitted.


m.invited_member_count	integer	The number of users with membership of invite. If this field has not changed since the last sync, it may be omitted. Required otherwise.
m.joined_member_count	integer	The number of users with membership of join, including the client’s own user ID. If this field has not changed since the last sync, it may be omitted. Required otherwise.
Timeline
Name	Type	Description
events	[ClientEventWithoutRoomID]	Required: List of events.
limited	boolean	True if the number of events returned was limited by the limit on the filter.
prev_batch	string	A token that can be supplied to the from parameter of the /rooms/<room_id>/messages endpoint in order to retrieve earlier events. If no earlier events are available, this property may be omitted from the response.
Unread Notification Counts
Name	Type	Description
highlight_count	Highlighted notification count	The number of unread notifications for this room with the highlight flag set.
notification_count	Total notification count	The total number of unread notifications for this room.
ThreadNotificationCounts
Name	Type	Description
highlight_count	ThreadedHighlightNotificationCount	The number of unread notifications for this thread with the highlight flag set.
notification_count	ThreadedTotalNotificationCount	The total number of unread notifications for this thread.
Knocked Room
Name	Type	Description
knock_state	KnockState	The stripped state of a room that the user has knocked upon.
KnockState
Name	Type	Description
events	[StrippedStateEvent]	The stripped state events that form the knock state.
Left Room
Name	Type	Description
account_data	Account Data	The private data that this user has attached to this room.
state	State	The state updates for the room up to the start of the timeline.
timeline	Timeline	The timeline of messages and state changes in the room up to the point when the user left.
{
  "account_data": {
    "events": [
      {
        "content": {
          "custom_config_key": "custom_config_value"
        },
        "type": "org.example.custom.config"
      }
    ]
  },
  "next_batch": "s72595_4483_1934",
  "presence": {
    "events": [
      {
        "content": {
          "avatar_url": "mxc://localhost/wefuiwegh8742w",
          "currently_active": false,
          "last_active_ago": 2478593,
          "presence": "online",
          "status_msg": "Making cupcakes"
        },
        "sender": "@example:localhost",
        "type": "m.presence"
      }
    ]
  },
  "rooms": {
    "invite": {
      "!696r7674:example.com": {
        "invite_state": {
          "events": [
            {
              "content": {
                "name": "My Room Name"
              },
              "sender": "@alice:example.com",
              "state_key": "",
              "type": "m.room.name"
            },
            {
              "content": {
                "membership": "invite"
              },
              "sender": "@alice:example.com",
              "state_key": "@bob:example.com",
              "type": "m.room.member"
            }
          ]
        }
      }
    },
    "join": {
      "!726s6s6q:example.com": {
        "account_data": {
          "events": [
            {
              "content": {
                "tags": {
                  "u.work": {
                    "order": 0.9
                  }
                }
              },
              "type": "m.tag"
            },
            {
              "content": {
                "custom_config_key": "custom_config_value"
              },
              "type": "org.example.custom.room.config"
            }
          ]
        },
        "ephemeral": {
          "events": [
            {
              "content": {
                "user_ids": [
                  "@alice:matrix.org",
                  "@bob:example.com"
                ]
              },
              "type": "m.typing"
            },
            {
              "content": {
                "$1435641916114394fHBLK:matrix.org": {
                  "m.read": {
                    "@rikj:jki.re": {
                      "ts": 1436451550453
                    }
                  },
                  "m.read.private": {
                    "@self:example.org": {
                      "ts": 1661384801651
                    }
                  }
                }
              },
              "type": "m.receipt"
            }
          ]
        },
        "state": {
          "events": [
            {
              "content": {
                "avatar_url": "mxc://example.org/SEsfnsuifSDFSSEF",
                "displayname": "Alice Margatroid",
                "membership": "join",
                "reason": "Looking for support"
              },
              "event_id": "$143273582443PhrSn:example.org",
              "origin_server_ts": 1432735824653,
              "room_id": "!jEsUZKDJdhlrceRyVU:example.org",
              "sender": "@example:example.org",
              "state_key": "@alice:example.org",
              "type": "m.room.member",
              "unsigned": {
                "age": 1234
              }
            }
          ]
        },
        "summary": {
          "m.heroes": [
            "@alice:example.com",
            "@bob:example.com"
          ],
          "m.invited_member_count": 0,
          "m.joined_member_count": 2
        },
        "timeline": {
          "events": [
            {
              "content": {
                "avatar_url": "mxc://example.org/SEsfnsuifSDFSSEF",
                "displayname": "Alice Margatroid",
                "membership": "join",
                "reason": "Looking for support"
              },
              "event_id": "$143273582443PhrSn:example.org",
              "origin_server_ts": 1432735824653,
              "room_id": "!jEsUZKDJdhlrceRyVU:example.org",
              "sender": "@example:example.org",
              "state_key": "@alice:example.org",
              "type": "m.room.member",
              "unsigned": {
                "age": 1234
              }
            },
            {
              "content": {
                "body": "This is an example text message",
                "format": "org.matrix.custom.html",
                "formatted_body": "<b>This is an example text message</b>",
                "msgtype": "m.text"
              },
              "event_id": "$143273582443PhrSn:example.org",
              "origin_server_ts": 1432735824653,
              "room_id": "!jEsUZKDJdhlrceRyVU:example.org",
              "sender": "@example:example.org",
              "type": "m.room.message",
              "unsigned": {
                "age": 1234
              }
            }
          ],
          "limited": true,
          "prev_batch": "t34-23535_0_0"
        },
        "unread_notifications": {
          "highlight_count": 1,
          "notification_count": 5
        },
        "unread_thread_notifications": {
          "$threadroot": {
            "highlight_count": 3,
            "notification_count": 6
          }
        }
      }
    },
    "knock": {
      "!223asd456:example.com": {
        "knock_state": {
          "events": [
            {
              "content": {
                "name": "My Room Name"
              },
              "sender": "@alice:example.com",
              "state_key": "",
              "type": "m.room.name"
            },
            {
              "content": {
                "membership": "knock"
              },
              "sender": "@bob:example.com",
              "state_key": "@bob:example.com",
              "type": "m.room.member"
            }
          ]
        }
      }
    },
    "leave": {}
  }
}
GET /_matrix/client/v3/events 
This API is deprecated and will be removed from a future release.

This will listen for new events and return them to the caller. This will block until an event is received, or until the timeout is reached.

This endpoint was deprecated in r0 of this specification. Clients should instead call the /sync endpoint with a since parameter. See the migration guide.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
from	string	The token to stream from. This token is either from a previous request to this API or from the initial sync API.
timeout	integer	The maximum time in milliseconds to wait for an event.
Responses
Status	Description
200	The events received, which may be none.
400	Bad pagination from parameter.
200 response
Name	Type	Description
chunk	[ClientEvent]	An array of events.
end	string	A token which correlates to the end of chunk. This token should be used in the next request to /events.
start	string	A token which correlates to the start of chunk. This is usually the same token supplied to from=.
ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "chunk": [
    {
      "content": {
        "body": "This is an example text message",
        "format": "org.matrix.custom.html",
        "formatted_body": "<b>This is an example text message</b>",
        "msgtype": "m.text"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!jEsUZKDJdhlrceRyVU:example.org",
      "sender": "@example:example.org",
      "type": "m.room.message",
      "unsigned": {
        "age": 1234
      }
    }
  ],
  "end": "s3457_9_0",
  "start": "s3456_9_0"
}
GET /_matrix/client/v3/events/{eventId} 
This API is deprecated and will be removed from a future release.

Get a single event based on event_id. You must have permission to retrieve this event e.g. by being a member in the room for this event.

This endpoint was deprecated in r0 of this specification. Clients should instead call the /rooms/{roomId}/event/{eventId} API or the /rooms/{roomId}/context/{eventId API.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventId	string	Required: The event ID to get.
Responses
Status	Description
200	The full event.
404	The event was not found or you do not have permission to read this event.
200 response
ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "content": {
    "body": "This is an example text message",
    "format": "org.matrix.custom.html",
    "formatted_body": "<b>This is an example text message</b>",
    "msgtype": "m.text"
  },
  "event_id": "$143273582443PhrSn:example.org",
  "origin_server_ts": 1432735824653,
  "room_id": "!jEsUZKDJdhlrceRyVU:example.org",
  "sender": "@example:example.org",
  "type": "m.room.message",
  "unsigned": {
    "age": 1234
  }
}
GET /_matrix/client/v3/initialSync 
This API is deprecated and will be removed from a future release.

This returns the full state for this user, with an optional limit on the number of messages per room to return.

This endpoint was deprecated in r0 of this specification. Clients should instead call the /sync endpoint with no since parameter. See the migration guide.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
archived	boolean	Whether to include rooms that the user has left. If false then only rooms that the user has been invited to or has joined are included. If set to true then rooms that the user has left are included as well. By default this is false.
limit	integer	The maximum number of messages to return for each room.
Responses
Status	Description
200	The user’s current state.
404	There is no avatar URL for this user or this user does not exist.
200 response
Name	Type	Description
account_data	[Event]	The global private data created by this user.
end	string	Required: A token which correlates to the end of the timelines returned. This token should be used with the /events endpoint to listen for new events.
presence	[ClientEvent]	Required: A list of presence events.
rooms	[RoomInfo]	Required:
Event
Name	Type	Description
content	object	Required: The fields in this object will vary depending on the type of event. When interacting with the REST API, this is the HTTP body.
type	string	Required: The type of event. This SHOULD be namespaced similar to Java package naming conventions e.g. ‘com.example.subdomain.event.type’
ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
RoomInfo
Name	Type	Description
account_data	[ClientEvent]	The private data that this user has attached to this room.
invite	InviteEvent	The invite event if membership is invite
membership	enum	Required: The user’s membership state in this room.

One of: [invite, join, leave, ban].


messages	PaginationChunk	The pagination chunk for this room.
room_id	string	Required: The ID of this room.
state	[ClientEvent]	If the user is a member of the room this will be the current state of the room as a list of events. If the user has left the room this will be the state of the room when they left it.
visibility	enum	Whether this room is visible to the /publicRooms API or not."

One of: [private, public].

InviteEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
PaginationChunk
Name	Type	Description
chunk	[ClientEvent]	Required: If the user is a member of the room this will be a list of the most recent messages for this room. If the user has left the room this will be the messages that preceded them leaving. This array will consist of at most limit elements.
end	string	Required: A token which correlates to the end of chunk. Can be passed to /rooms/<room_id>/messages to retrieve later events.
start	string	

A token which correlates to the start of chunk. Can be passed to /rooms/<room_id>/messages to retrieve earlier events.

If no earlier events are available, this property may be omitted from the response.

{
  "account_data": [
    {
      "content": {
        "custom_config_key": "custom_config_value"
      },
      "type": "org.example.custom.config"
    }
  ],
  "end": "s3456_9_0",
  "presence": [
    {
      "content": {
        "avatar_url": "mxc://localhost/wefuiwegh8742w",
        "currently_active": false,
        "last_active_ago": 2478593,
        "presence": "online",
        "status_msg": "Making cupcakes"
      },
      "sender": "@example:localhost",
      "type": "m.presence"
    }
  ],
  "rooms": [
    {
      "account_data": [
        {
          "content": {
            "tags": {
              "work": {
                "order": 1
              }
            }
          },
          "type": "m.tag"
        },
        {
          "content": {
            "custom_config_key": "custom_config_value"
          },
          "type": "org.example.custom.room.config"
        }
      ],
      "membership": "join",
      "messages": {
        "chunk": [
          {
            "content": {
              "body": "This is an example text message",
              "format": "org.matrix.custom.html",
              "formatted_body": "<b>This is an example text message</b>",
              "msgtype": "m.text"
            },
            "event_id": "$143273582443PhrSn:example.org",
            "origin_server_ts": 1432735824653,
            "room_id": "!TmaZBKYIFrIPVGoUYp:localhost",
            "sender": "@example:example.org",
            "type": "m.room.message",
            "unsigned": {
              "age": 1234
            }
          },
          {
            "content": {
              "body": "Gangnam Style",
              "info": {
                "duration": 2140786,
                "h": 320,
                "mimetype": "video/mp4",
                "size": 1563685,
                "thumbnail_info": {
                  "h": 300,
                  "mimetype": "image/jpeg",
                  "size": 46144,
                  "w": 300
                },
                "thumbnail_url": "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe",
                "w": 480
              },
              "msgtype": "m.video",
              "url": "mxc://example.org/a526eYUSFFxlgbQYZmo442"
            },
            "event_id": "$143273582443PhrSn:example.org",
            "origin_server_ts": 1432735824653,
            "room_id": "!TmaZBKYIFrIPVGoUYp:localhost",
            "sender": "@example:example.org",
            "type": "m.room.message",
            "unsigned": {
              "age": 1234
            }
          }
        ],
        "end": "s3456_9_0",
        "start": "t44-3453_9_0"
      },
      "room_id": "!TmaZBKYIFrIPVGoUYp:localhost",
      "state": [
        {
          "content": {
            "join_rule": "public"
          },
          "event_id": "$143273582443PhrSn:example.org",
          "origin_server_ts": 1432735824653,
          "room_id": "!TmaZBKYIFrIPVGoUYp:localhost",
          "sender": "@example:example.org",
          "state_key": "",
          "type": "m.room.join_rules",
          "unsigned": {
            "age": 1234
          }
        },
        {
          "content": {
            "avatar_url": "mxc://example.org/SEsfnsuifSDFSSEF",
            "displayname": "Alice Margatroid",
            "membership": "join",
            "reason": "Looking for support"
          },
          "event_id": "$143273582443PhrSn:example.org",
          "origin_server_ts": 1432735824653,
          "room_id": "!TmaZBKYIFrIPVGoUYp:localhost",
          "sender": "@example:example.org",
          "state_key": "@alice:example.org",
          "type": "m.room.member",
          "unsigned": {
            "age": 1234
          }
        },
        {
          "content": {
            "creator": "@example:example.org",
            "m.federate": true,
            "predecessor": {
              "event_id": "$something:example.org",
              "room_id": "!oldroom:example.org"
            },
            "room_version": "1"
          },
          "event_id": "$143273582443PhrSn:example.org",
          "origin_server_ts": 1432735824653,
          "room_id": "!TmaZBKYIFrIPVGoUYp:localhost",
          "sender": "@example:example.org",
          "state_key": "",
          "type": "m.room.create",
          "unsigned": {
            "age": 1234
          }
        },
        {
          "content": {
            "ban": 50,
            "events": {
              "m.room.name": 100,
              "m.room.power_levels": 100
            },
            "events_default": 0,
            "invite": 50,
            "kick": 50,
            "notifications": {
              "room": 20
            },
            "redact": 50,
            "state_default": 50,
            "users": {
              "@example:localhost": 100
            },
            "users_default": 0
          },
          "event_id": "$143273582443PhrSn:example.org",
          "origin_server_ts": 1432735824653,
          "room_id": "!TmaZBKYIFrIPVGoUYp:localhost",
          "sender": "@example:example.org",
          "state_key": "",
          "type": "m.room.power_levels",
          "unsigned": {
            "age": 1234
          }
        }
      ],
      "visibility": "private"
    }
  ]
}
GET /_matrix/client/v3/rooms/{roomId}/event/{eventId} 

Get a single event based on roomId/eventId. You must have permission to retrieve this event e.g. by being a member in the room for this event.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventId	string	Required: The event ID to get.
roomId	string	Required: The ID of the room the event is in.
Responses
Status	Description
200	The full event.
404	The event was not found or you do not have permission to read this event.
200 response
ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "content": {
    "body": "This is an example text message",
    "format": "org.matrix.custom.html",
    "formatted_body": "<b>This is an example text message</b>",
    "msgtype": "m.text"
  },
  "event_id": "$143273582443PhrSn:example.org",
  "origin_server_ts": 1432735824653,
  "room_id": "!636q39766251:matrix.org",
  "sender": "@example:example.org",
  "type": "m.room.message",
  "unsigned": {
    "age": 1234
  }
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Event not found."
}
GET /_matrix/client/v3/rooms/{roomId}/joined_members 

This API returns a map of MXIDs to member info objects for members of the room. The current user must be in the room for it to work, unless it is an Application Service in which case any of the AS’s users must be in the room. This API is primarily for Application Services and should be faster to respond than /members as it can be implemented more efficiently on the server.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room to get the members of.
Responses
Status	Description
200	A map of MXID to room member objects.
403	You aren’t a member of the room.
200 response
Name	Type	Description
joined	{string: RoomMember}	A map from user ID to a RoomMember object.
RoomMember
Name	Type	Description
avatar_url	string	The mxc avatar url of the user this object is representing.
display_name	string	The display name of the user this object is representing.
{
  "joined": {
    "@bar:example.com": {
      "avatar_url": "mxc://riot.ovh/printErCATzZijQsSDWorRaK",
      "display_name": "Bar"
    }
  }
}
GET /_matrix/client/v3/rooms/{roomId}/members 

Get the list of members for this room.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room to get the member events for.
query parameters
Name	Type	Description
at	string	The point in time (pagination token) to return members for in the room. This token can be obtained from a prev_batch token returned for each room by the sync API. Defaults to the current state of the room, as determined by the server.
membership	enum	The kind of membership to filter for. Defaults to no filtering if unspecified. When specified alongside not_membership, the two parameters create an ‘or’ condition: either the membership is the same as membership or is not the same as not_membership.

One of: [join, invite, knock, leave, ban].


not_membership	enum	The kind of membership to exclude from the results. Defaults to no filtering if unspecified.

One of: [join, invite, knock, leave, ban].

Responses
Status	Description
200	A list of members of the room. If you are joined to the room then this will be the current members of the room. If you have left the room then this will be the members of the room when you left.
403	You aren’t a member of the room and weren’t previously a member of the room.
200 response
Name	Type	Description
chunk	[ClientEvent]	
ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "chunk": [
    {
      "content": {
        "avatar_url": "mxc://example.org/SEsfnsuifSDFSSEF",
        "displayname": "Alice Margatroid",
        "membership": "join",
        "reason": "Looking for support"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "state_key": "@alice:example.org",
      "type": "m.room.member",
      "unsigned": {
        "age": 1234
      }
    }
  ]
}
GET /_matrix/client/v3/rooms/{roomId}/state 

Get the state events for the current state of a room.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room to look up the state for.
Responses
Status	Description
200	The current state of the room
403	You aren’t a member of the room and weren’t previously a member of the room.
200 response

Array of ClientEvent.

ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
[
  {
    "content": {
      "join_rule": "public"
    },
    "event_id": "$143273582443PhrSn:example.org",
    "origin_server_ts": 1432735824653,
    "room_id": "!636q39766251:example.com",
    "sender": "@example:example.org",
    "state_key": "",
    "type": "m.room.join_rules",
    "unsigned": {
      "age": 1234
    }
  },
  {
    "content": {
      "avatar_url": "mxc://example.org/SEsfnsuifSDFSSEF",
      "displayname": "Alice Margatroid",
      "membership": "join",
      "reason": "Looking for support"
    },
    "event_id": "$143273582443PhrSn:example.org",
    "origin_server_ts": 1432735824653,
    "room_id": "!636q39766251:example.com",
    "sender": "@example:example.org",
    "state_key": "@alice:example.org",
    "type": "m.room.member",
    "unsigned": {
      "age": 1234
    }
  },
  {
    "content": {
      "creator": "@example:example.org",
      "m.federate": true,
      "predecessor": {
        "event_id": "$something:example.org",
        "room_id": "!oldroom:example.org"
      },
      "room_version": "1"
    },
    "event_id": "$143273582443PhrSn:example.org",
    "origin_server_ts": 1432735824653,
    "room_id": "!636q39766251:example.com",
    "sender": "@example:example.org",
    "state_key": "",
    "type": "m.room.create",
    "unsigned": {
      "age": 1234
    }
  },
  {
    "content": {
      "ban": 50,
      "events": {
        "m.room.name": 100,
        "m.room.power_levels": 100
      },
      "events_default": 0,
      "invite": 50,
      "kick": 50,
      "notifications": {
        "room": 20
      },
      "redact": 50,
      "state_default": 50,
      "users": {
        "@example:localhost": 100
      },
      "users_default": 0
    },
    "event_id": "$143273582443PhrSn:example.org",
    "origin_server_ts": 1432735824653,
    "room_id": "!636q39766251:example.com",
    "sender": "@example:example.org",
    "state_key": "",
    "type": "m.room.power_levels",
    "unsigned": {
      "age": 1234
    }
  }
]
GET /_matrix/client/v3/rooms/{roomId}/state/{eventType}/{stateKey} 

Looks up the contents of a state event in a room. If the user is joined to the room then the state is taken from the current state of the room. If the user has left the room then the state is taken from the state of the room when they left.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventType	string	Required: The type of state to look up.
roomId	string	Required: The room to look up the state in.
stateKey	string	Required: The key of the state to look up. Defaults to an empty string. When an empty string, the trailing slash on this endpoint is optional.
Responses
Status	Description
200	The content of the state event.
403	You aren’t a member of the room and weren’t previously a member of the room.
404	The room has no state with the given type or key.
200 response
{
  "name": "Example room name"
}
GET /_matrix/client/v3/rooms/{roomId}/messages 

This API returns a list of message and state events for a room. It uses pagination query parameters to paginate history in the room.

Note: This endpoint supports lazy-loading of room member events. See Lazy-loading room members for more information.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room to get events from.
query parameters
Name	Type	Description
dir	enum	Required: The direction to return events from. If this is set to f, events will be returned in chronological order starting at from. If it is set to b, events will be returned in reverse chronological order, again starting at from.

One of: [b, f].


filter	string	A JSON RoomEventFilter to filter returned events with.
from	string	

The token to start returning events from. This token can be obtained from a prev_batch or next_batch token returned by the /sync endpoint, or from an end token returned by a previous request to this endpoint.

This endpoint can also accept a value returned as a start token by a previous request to this endpoint, though servers are not required to support this. Clients should not rely on the behaviour.

If it is not provided, the homeserver shall return a list of messages from the first or last (per the value of the dir parameter) visible event in the room history for the requesting user.



Changed in v1.3: Previously, this field was required and paginating from the first or last visible event in the room history wasn’t supported.
limit	integer	The maximum number of events to return. Default: 10.
to	string	The token to stop returning events at. This token can be obtained from a prev_batch or next_batch token returned by the /sync endpoint, or from an end token returned by a previous request to this endpoint.
Responses
Status	Description
200	A list of messages with a new token to request more.
403	You aren’t a member of the room.
200 response
Name	Type	Description
chunk	[ClientEvent]	Required:

A list of room events. The order depends on the dir parameter. For dir=b events will be in reverse-chronological order, for dir=f in chronological order. (The exact definition of chronological is dependent on the server implementation.)

Note that an empty chunk does not necessarily imply that no more events are available. Clients should continue to paginate until no end property is returned.


end	string	

A token corresponding to the end of chunk. This token can be passed back to this endpoint to request further events.

If no further events are available (either because we have reached the start of the timeline, or because the user does not have permission to see any more events), this property is omitted from the response.


start	string	Required: A token corresponding to the start of chunk. This will be the same as the value given in from.
state	[ClientEvent]	

A list of state events relevant to showing the chunk. For example, if lazy_load_members is enabled in the filter then this may contain the membership events for the senders of events in the chunk.

Unless include_redundant_members is true, the server may remove membership events which would have already been sent to the client in prior calls to this endpoint, assuming the membership of those members has not changed.

ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "chunk": [
    {
      "content": {
        "body": "This is an example text message",
        "format": "org.matrix.custom.html",
        "formatted_body": "<b>This is an example text message</b>",
        "msgtype": "m.text"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "type": "m.room.message",
      "unsigned": {
        "age": 1234
      }
    },
    {
      "content": {
        "name": "The room name"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "state_key": "",
      "type": "m.room.name",
      "unsigned": {
        "age": 1234
      }
    },
    {
      "content": {
        "body": "Gangnam Style",
        "info": {
          "duration": 2140786,
          "h": 320,
          "mimetype": "video/mp4",
          "size": 1563685,
          "thumbnail_info": {
            "h": 300,
            "mimetype": "image/jpeg",
            "size": 46144,
            "w": 300
          },
          "thumbnail_url": "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe",
          "w": 480
        },
        "msgtype": "m.video",
        "url": "mxc://example.org/a526eYUSFFxlgbQYZmo442"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "type": "m.room.message",
      "unsigned": {
        "age": 1234
      }
    }
  ],
  "end": "t47409-4357353_219380_26003_2265",
  "start": "t47429-4392820_219380_26003_2265"
}
GET /_matrix/client/v1/rooms/{roomId}/timestamp_to_event 

Added in v1.6

Get the ID of the event closest to the given timestamp, in the direction specified by the dir parameter.

If the server does not have all of the room history and does not have an event suitably close to the requested timestamp, it can use the corresponding federation endpoint to ask other servers for a suitable event.

After calling this endpoint, clients can call /rooms/{roomId}/context/{eventId} to obtain a pagination token to retrieve the events around the returned event.

The event returned by this endpoint could be an event that the client cannot render, and so may need to paginate in order to locate an event that it can display, which may end up being outside of the client’s suitable range. Clients can employ different strategies to display something reasonable to the user. For example, the client could try paginating in one direction for a while, while looking at the timestamps of the events that it is paginating through, and if it exceeds a certain difference from the target timestamp, it can try paginating in the opposite direction. The client could also simply paginate in one direction and inform the user that the closest event found in that direction is outside of the expected range.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room to search
query parameters
Name	Type	Description
dir	enum	Required: The direction in which to search. f for forwards, b for backwards.

One of: [f, b].


ts	integer	Required: The timestamp to search from, as given in milliseconds since the Unix epoch.
Responses
Status	Description
200	An event was found matching the search parameters.
404	No event was found.
429	This request was rate-limited.
200 response
Name	Type	Description
event_id	string	Required: The ID of the event found
origin_server_ts	integer	Required: The event’s timestamp, in milliseconds since the Unix epoch. This makes it easy to do a quick comparison to see if the event_id fetched is too far out of range to be useful for your use case.
{
  "event_id": "$143273582443PhrSn:example.org",
  "origin_server_ts": 1432735824653
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unable to find event from 1432684800000 in forward direction"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/rooms/{roomId}/initialSync 
This API is deprecated and will be removed from a future release.

Get a copy of the current state and the most recent messages in a room.

This endpoint was deprecated in r0 of this specification. There is no direct replacement; the relevant information is returned by the /sync API. See the migration guide.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room to get the data.
Responses
Status	Description
200	The current state of the room
403	You aren’t a member of the room and weren’t previously a member of the room.
200 response
RoomInfo
Name	Type	Description
account_data	[Event]	The private data that this user has attached to this room.
membership	enum	The user’s membership state in this room.

One of: [invite, join, leave, ban].


messages	PaginationChunk	The pagination chunk for this room.
room_id	string	Required: The ID of this room.
state	[ClientEvent]	If the user is a member of the room this will be the current state of the room as a list of events. If the user has left the room this will be the state of the room when they left it.
visibility	enum	Whether this room is visible to the /publicRooms API or not."

One of: [private, public].

Event
Name	Type	Description
content	object	Required: The fields in this object will vary depending on the type of event. When interacting with the REST API, this is the HTTP body.
type	string	Required: The type of event. This SHOULD be namespaced similar to Java package naming conventions e.g. ‘com.example.subdomain.event.type’
PaginationChunk
Name	Type	Description
chunk	[ClientEvent]	Required: If the user is a member of the room this will be a list of the most recent messages for this room. If the user has left the room this will be the messages that preceded them leaving. This array will consist of at most limit elements.
end	string	Required: A token which correlates to the end of chunk. Can be passed to /rooms/<room_id>/messages to retrieve later events.
start	string	

A token which correlates to the start of chunk. Can be passed to /rooms/<room_id>/messages to retrieve earlier events.

If no earlier events are available, this property may be omitted from the response.

ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "account_data": [
    {
      "content": {
        "tags": {
          "work": {
            "order": "1"
          }
        }
      },
      "type": "m.tag"
    }
  ],
  "membership": "join",
  "messages": {
    "chunk": [
      {
        "content": {
          "body": "This is an example text message",
          "format": "org.matrix.custom.html",
          "formatted_body": "<b>This is an example text message</b>",
          "msgtype": "m.text"
        },
        "event_id": "$143273582443PhrSn:example.org",
        "origin_server_ts": 1432735824653,
        "room_id": "!636q39766251:example.com",
        "sender": "@example:example.org",
        "type": "m.room.message",
        "unsigned": {
          "age": 1234
        }
      },
      {
        "content": {
          "body": "something-important.doc",
          "filename": "something-important.doc",
          "info": {
            "mimetype": "application/msword",
            "size": 46144
          },
          "msgtype": "m.file",
          "url": "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe"
        },
        "event_id": "$143273582443PhrSn:example.org",
        "origin_server_ts": 1432735824653,
        "room_id": "!636q39766251:example.com",
        "sender": "@example:example.org",
        "type": "m.room.message",
        "unsigned": {
          "age": 1234
        }
      }
    ],
    "end": "s3456_9_0",
    "start": "t44-3453_9_0"
  },
  "room_id": "!636q39766251:example.com",
  "state": [
    {
      "content": {
        "join_rule": "public"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "state_key": "",
      "type": "m.room.join_rules",
      "unsigned": {
        "age": 1234
      }
    },
    {
      "content": {
        "avatar_url": "mxc://example.org/SEsfnsuifSDFSSEF",
        "displayname": "Alice Margatroid",
        "membership": "join",
        "reason": "Looking for support"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "state_key": "@alice:example.org",
      "type": "m.room.member",
      "unsigned": {
        "age": 1234
      }
    },
    {
      "content": {
        "creator": "@example:example.org",
        "m.federate": true,
        "predecessor": {
          "event_id": "$something:example.org",
          "room_id": "!oldroom:example.org"
        },
        "room_version": "1"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "state_key": "",
      "type": "m.room.create",
      "unsigned": {
        "age": 1234
      }
    },
    {
      "content": {
        "ban": 50,
        "events": {
          "m.room.name": 100,
          "m.room.power_levels": 100
        },
        "events_default": 0,
        "invite": 50,
        "kick": 50,
        "notifications": {
          "room": 20
        },
        "redact": 50,
        "state_default": 50,
        "users": {
          "@example:localhost": 100
        },
        "users_default": 0
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "state_key": "",
      "type": "m.room.power_levels",
      "unsigned": {
        "age": 1234
      }
    }
  ],
  "visibility": "private"
}
PUT /_matrix/client/v3/rooms/{roomId}/state/{eventType}/{stateKey} 

State events can be sent using this endpoint. These events will be overwritten if <room id>, <event type> and <state key> all match.

Requests to this endpoint cannot use transaction IDs like other PUT paths because they cannot be differentiated from the state_key. Furthermore, POST is unsupported on state paths.

The body of the request should be the content object of the event; the fields in this object will vary depending on the type of event. See Room Events for the m. event specification.

If the event type being sent is m.room.canonical_alias servers SHOULD ensure that any new aliases being listed in the event are valid per their grammar/syntax and that they point to the room ID where the state event is to be sent. Servers do not validate aliases which are being removed or are already present in the state event.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventType	string	Required: The type of event to send.
roomId	string	Required: The room to set the state in
stateKey	string	Required: The state_key for the state to send. Defaults to the empty string. When an empty string, the trailing slash on this endpoint is optional.
Request body
Request body example
{
  "avatar_url": "mxc://localhost/SEsfnsuifSDFSSEF",
  "displayname": "Alice Margatroid",
  "membership": "join"
}

Responses
Status	Description
200	An ID for the sent event.
400	

The sender’s request is malformed.

Some example error codes include:

M_INVALID_PARAM: One or more aliases within the m.room.canonical_alias event have invalid syntax.

M_BAD_ALIAS: One or more aliases within the m.room.canonical_alias event do not point to the room ID for which the state event is to be sent to.


403	The sender doesn’t have permission to send the event into the room.
200 response
Name	Type	Description
event_id	string	Required: A unique identifier for the event.
{
  "event_id": "$YUwRidLecu:example.com"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_BAD_ALIAS",
  "error": "The alias '#hello:example.org' does not point to this room."
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You do not have permission to send the event."
}
PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId} 

This endpoint is used to send a message event to a room. Message events allow access to historical events and pagination, making them suited for “once-off” activity in a room.

The body of the request should be the content object of the event; the fields in this object will vary depending on the type of event. See Room Events for the m. event specification.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventType	string	Required: The type of event to send.
roomId	string	Required: The room to send the event to.
txnId	string	Required: The transaction ID for this event. Clients should generate an ID unique across requests with the same access token; it will be used by the server to ensure idempotency of requests.
Request body
Request body example
{
  "body": "hello",
  "msgtype": "m.text"
}

Responses
Status	Description
200	An ID for the sent event.
200 response
Name	Type	Description
event_id	string	Required: A unique identifier for the event.
{
  "event_id": "$YUwRidLecu:example.com"
}
PUT /_matrix/client/v3/rooms/{roomId}/redact/{eventId}/{txnId} 

Strips all information out of an event which isn’t critical to the integrity of the server-side representation of the room.

This cannot be undone.

Any user with a power level greater than or equal to the m.room.redaction event power level may send redaction events in the room. If the user’s power level greater is also greater than or equal to the redact power level of the room, the user may redact events sent by other users.

Server administrators may redact events sent by users on their server.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventId	string	Required: The ID of the event to redact
roomId	string	Required: The room from which to redact the event.
txnId	string	Required: The transaction ID for this event. Clients should generate a unique ID; it will be used by the server to ensure idempotency of requests.
Request body
Name	Type	Description
reason	string	The reason for the event being redacted.
Request body example
{
  "reason": "Indecent material"
}

Responses
Status	Description
200	An ID for the redaction event.
200 response
Name	Type	Description
event_id	string	A unique identifier for the event.
{
  "event_id": "$YUwQidLecu:example.com"
}
GET /_matrix/client/v1/rooms/{roomId}/relations/{eventId} 

Retrieve all of the child events for a given parent event.

Note that when paginating the from token should be “after” the to token in terms of topological ordering, because it is only possible to paginate “backwards” through events, starting at from.

For example, passing a from token from page 2 of the results, and a to token from page 1, would return the empty set. The caller can use a from token from page 1 and a to token from page 2 to paginate over the same range, however.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventId	string	Required: The ID of the parent event whose child events are to be returned.
roomId	string	Required: The ID of the room containing the parent event.
query parameters
Name	Type	Description
dir	enum	Optional (default b) direction to return events from. If this is set to f, events will be returned in chronological order starting at from. If it is set to b, events will be returned in reverse chronological order, again starting at from.

One of: [b, f].

Added in v1.4


from	string	

The pagination token to start returning results from. If not supplied, results start at the most recent topological event known to the server.

Can be a next_batch or prev_batch token from a previous call, or a returned start token from /messages, or a next_batch token from /sync.


limit	integer	

The maximum number of results to return in a single chunk. The server can and should apply a maximum value to this parameter to avoid large responses.

Similarly, the server should apply a default value when not supplied.


to	string	

The pagination token to stop returning results at. If not supplied, results continue up to limit or until there are no more events.

Like from, this can be a previous token from a prior call to this endpoint or from /messages or /sync.

Responses
Status	Description
200	The paginated child events which point to the parent. If no events are pointing to the parent or the pagination yields no results, an empty chunk is returned.
404	The parent event was not found or the user does not have permission to read this event (it might be contained in history that is not accessible to the user).
200 response
Name	Type	Description
chunk	ChildEventsChunk	Required: The child events of the requested event, ordered topologically most-recent first.
next_batch	string	An opaque string representing a pagination token. The absence of this token means there are no more results to fetch and the client should stop paginating.
prev_batch	string	An opaque string representing a pagination token. The absence of this token means this is the start of the result set, i.e. this is the first batch/page.
ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "chunk": [
    {
      "content": {
        "m.relates_to": {
          "event_id": "$asfDuShaf7Gafaw",
          "rel_type": "org.example.my_relation"
        }
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:matrix.org",
      "sender": "@example:example.org",
      "type": "m.room.message",
      "unsigned": {
        "age": 1234
      }
    }
  ],
  "next_batch": "page2_token",
  "prev_batch": "page1_token"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Event not found."
}
GET /_matrix/client/v1/rooms/{roomId}/relations/{eventId}/{relType} 

Retrieve all of the child events for a given parent event which relate to the parent using the given relType.

Note that when paginating the from token should be “after” the to token in terms of topological ordering, because it is only possible to paginate “backwards” through events, starting at from.

For example, passing a from token from page 2 of the results, and a to token from page 1, would return the empty set. The caller can use a from token from page 1 and a to token from page 2 to paginate over the same range, however.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventId	string	Required: The ID of the parent event whose child events are to be returned.
relType	string	Required: The relationship type to search for.
roomId	string	Required: The ID of the room containing the parent event.
query parameters
Name	Type	Description
dir	enum	Optional (default b) direction to return events from. If this is set to f, events will be returned in chronological order starting at from. If it is set to b, events will be returned in reverse chronological order, again starting at from.

One of: [b, f].

Added in v1.4


from	string	

The pagination token to start returning results from. If not supplied, results start at the most recent topological event known to the server.

Can be a next_batch or prev_batch token from a previous call, or a returned start token from /messages, or a next_batch token from /sync.


limit	integer	

The maximum number of results to return in a single chunk. The server can and should apply a maximum value to this parameter to avoid large responses.

Similarly, the server should apply a default value when not supplied.


to	string	

The pagination token to stop returning results at. If not supplied, results continue up to limit or until there are no more events.

Like from, this can be a previous token from a prior call to this endpoint or from /messages or /sync.

Responses
Status	Description
200	The paginated child events which point to the parent. If no events are pointing to the parent or the pagination yields no results, an empty chunk is returned.
404	The parent event was not found or the user does not have permission to read this event (it might be contained in history that is not accessible to the user).
200 response
Name	Type	Description
chunk	ChildEventsChunk	Required: The child events of the requested event, ordered topologically most-recent first. The events returned will match the relType supplied in the URL.
next_batch	string	An opaque string representing a pagination token. The absence of this token means there are no more results to fetch and the client should stop paginating.
prev_batch	string	An opaque string representing a pagination token. The absence of this token means this is the start of the result set, i.e. this is the first batch/page.
ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "chunk": [
    {
      "content": {
        "m.relates_to": {
          "event_id": "$asfDuShaf7Gafaw",
          "rel_type": "org.example.my_relation"
        }
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:matrix.org",
      "sender": "@example:example.org",
      "type": "m.room.message",
      "unsigned": {
        "age": 1234
      }
    }
  ],
  "next_batch": "page2_token",
  "prev_batch": "page1_token"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Event not found."
}
GET /_matrix/client/v1/rooms/{roomId}/relations/{eventId}/{relType}/{eventType} 

Retrieve all of the child events for a given parent event which relate to the parent using the given relType and have the given eventType.

Note that when paginating the from token should be “after” the to token in terms of topological ordering, because it is only possible to paginate “backwards” through events, starting at from.

For example, passing a from token from page 2 of the results, and a to token from page 1, would return the empty set. The caller can use a from token from page 1 and a to token from page 2 to paginate over the same range, however.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventId	string	Required: The ID of the parent event whose child events are to be returned.
eventType	string	Required:

The event type of child events to search for.

Note that in encrypted rooms this will typically always be m.room.encrypted regardless of the event type contained within the encrypted payload.


relType	string	Required: The relationship type to search for.
roomId	string	Required: The ID of the room containing the parent event.
query parameters
Name	Type	Description
dir	enum	Optional (default b) direction to return events from. If this is set to f, events will be returned in chronological order starting at from. If it is set to b, events will be returned in reverse chronological order, again starting at from.

One of: [b, f].

Added in v1.4


from	string	

The pagination token to start returning results from. If not supplied, results start at the most recent topological event known to the server.

Can be a next_batch or prev_batch token from a previous call, or a returned start token from /messages, or a next_batch token from /sync.


limit	integer	

The maximum number of results to return in a single chunk. The server can and should apply a maximum value to this parameter to avoid large responses.

Similarly, the server should apply a default value when not supplied.


to	string	

The pagination token to stop returning results at. If not supplied, results continue up to limit or until there are no more events.

Like from, this can be a previous token from a prior call to this endpoint or from /messages or /sync.

Responses
Status	Description
200	The paginated child events which point to the parent. If no events are pointing to the parent or the pagination yields no results, an empty chunk is returned.
404	The parent event was not found or the user does not have permission to read this event (it might be contained in history that is not accessible to the user).
200 response
Name	Type	Description
chunk	ChildEventsChunk	Required: The child events of the requested event, ordered topologically most-recent first. The events returned will match the relType and eventType supplied in the URL.
next_batch	string	An opaque string representing a pagination token. The absence of this token means there are no more results to fetch and the client should stop paginating.
prev_batch	string	An opaque string representing a pagination token. The absence of this token means this is the start of the result set, i.e. this is the first batch/page.
ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "chunk": [
    {
      "content": {
        "m.relates_to": {
          "event_id": "$asfDuShaf7Gafaw",
          "rel_type": "org.example.my_relation"
        }
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:matrix.org",
      "sender": "@example:example.org",
      "type": "m.room.message",
      "unsigned": {
        "age": 1234
      }
    }
  ],
  "next_batch": "page2_token",
  "prev_batch": "page1_token"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Event not found."
}
POST /_matrix/client/v3/createRoom 

Create a new room with various configuration options.

The server MUST apply the normal state resolution rules when creating the new room, including checking power levels for each event. It MUST apply the events implied by the request in the following order:

The m.room.create event itself. Must be the first event in the room.

An m.room.member event for the creator to join the room. This is needed so the remaining events can be sent.

A default m.room.power_levels event, giving the room creator (and not other members) permission to send state events. Overridden by the power_level_content_override parameter.

An m.room.canonical_alias event if room_alias_name is given.

Events set by the preset. Currently these are the m.room.join_rules, m.room.history_visibility, and m.room.guest_access state events.

Events listed in initial_state, in the order that they are listed.

Events implied by name and topic (m.room.name and m.room.topic state events).

Invite events implied by invite and invite_3pid (m.room.member with membership: invite and m.room.third_party_invite).

The available presets do the following with respect to room state:

Preset	join_rules	history_visibility	guest_access	Other
private_chat	invite	shared	can_join	
trusted_private_chat	invite	shared	can_join	All invitees are given the same power level as the room creator.
public_chat	public	shared	forbidden	

The server will create a m.room.create event in the room with the requesting user as the creator, alongside other keys provided in the creation_content.

Rate-limited:	No
Requires authentication:	Yes
Request
Request body
Name	Type	Description
creation_content	CreationContent	Extra keys, such as m.federate, to be added to the content of the m.room.create event. The server will overwrite the following keys: creator, room_version. Future versions of the specification may allow the server to overwrite other keys.
initial_state	[StateEvent]	

A list of state events to set in the new room. This allows the user to override the default state events set in the new room. The expected format of the state events are an object with type, state_key and content keys set.

Takes precedence over events set by preset, but gets overridden by name and topic keys.


invite	[string]	A list of user IDs to invite to the room. This will tell the server to invite everyone in the list to the newly created room.
invite_3pid	[Invite3pid]	A list of objects representing third party IDs to invite into the room.
is_direct	boolean	This flag makes the server set the is_direct flag on the m.room.member events sent to the users in invite and invite_3pid. See Direct Messaging for more information.
name	string	If this is included, an m.room.name event will be sent into the room to indicate the name of the room. See Room Events for more information on m.room.name.
power_level_content_override	Power Level Event Content	The power level content to override in the default power level event. This object is applied on top of the generated m.room.power_levels event content prior to it being sent to the room. Defaults to overriding nothing.
preset	enum	

Convenience parameter for setting various default state events based on a preset.

If unspecified, the server should use the visibility to determine which preset to use. A visbility of public equates to a preset of public_chat and private visibility equates to a preset of private_chat.

One of: [private_chat, public_chat, trusted_private_chat].


room_alias_name	string	

The desired room alias local part. If this is included, a room alias will be created and mapped to the newly created room. The alias will belong on the same homeserver which created the room. For example, if this was set to “foo” and sent to the homeserver “example.com” the complete room alias would be #foo:example.com.

The complete room alias will become the canonical alias for the room and an m.room.canonical_alias event will be sent into the room.


room_version	string	The room version to set for the room. If not provided, the homeserver is to use its configured default. If provided, the homeserver will return a 400 error with the errcode M_UNSUPPORTED_ROOM_VERSION if it does not support the room version.
topic	string	If this is included, an m.room.topic event will be sent into the room to indicate the topic for the room. See Room Events for more information on m.room.topic.
visibility	enum	A public visibility indicates that the room will be shown in the published room list. A private visibility will hide the room from the published room list. Rooms default to private visibility if this key is not included. NB: This should not be confused with join_rules which also uses the word public.

One of: [public, private].

StateEvent
Name	Type	Description
content	object	Required: The content of the event.
state_key	string	The state_key of the state event. Defaults to an empty string.
type	string	Required: The type of event to send.
Invite3pid
Name	Type	Description
address	string	Required: The invitee’s third party identifier.
id_access_token	string	Required: An access token previously registered with the identity server. Servers can treat this as optional to distinguish between r0.5-compatible clients and this specification version.
id_server	string	Required: The hostname+port of the identity server which should be used for third party identifier lookups.
medium	string	Required: The kind of address being passed in the address field, for example email (see the list of recognised values).
Request body example
{
  "creation_content": {
    "m.federate": false
  },
  "name": "The Grand Duke Pub",
  "preset": "public_chat",
  "room_alias_name": "thepub",
  "topic": "All about happy hour"
}

Responses
Status	Description
200	Information about the newly created room.
400	

The request is invalid. A meaningful errcode and description error text will be returned. Example reasons for rejection include:

The request body is malformed (errcode set to M_BAD_JSON or M_NOT_JSON).

The room alias specified is already taken (errcode set to M_ROOM_IN_USE).

The initial state implied by the parameters to the request is invalid: for example, the user’s power_level is set below that necessary to set the room name (errcode set to M_INVALID_ROOM_STATE).

The homeserver doesn’t support the requested room version, or one or more users being invited to the new room are residents of a homeserver which does not support the requested room version. The errcode will be M_UNSUPPORTED_ROOM_VERSION in these cases.

200 response
Name	Type	Description
room_id	string	Required: The created room’s ID.
{
  "room_id": "!sefiuhWgwghwWgh:example.com"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN",
  "error": "An unknown error occurred"
}
GET /_matrix/client/v3/directory/room/{roomAlias} 

Requests that the server resolve a room alias to a room ID.

The server will use the federation API to resolve the alias if the domain part of the alias does not correspond to the server’s own domain.

Rate-limited:	No
Requires authentication:	No
Request
Request parameters
path parameters
Name	Type	Description
roomAlias	string	Required: The room alias. Its format is defined in the appendices.
Responses
Status	Description
200	The room ID and other information for this alias.
400	The given roomAlias is not a valid room alias.
404	There is no mapped room ID for this room alias.
200 response
Name	Type	Description
room_id	string	The room ID for this room alias.
servers	[string]	A list of servers that are aware of this room alias.
{
  "room_id": "!abnjk1jdasj98:capuchins.com",
  "servers": [
    "capuchins.com",
    "matrix.org",
    "another.com"
  ]
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_INVALID_PARAM",
  "error": "Room alias invalid"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Room alias #monkeys:matrix.org not found."
}
PUT /_matrix/client/v3/directory/room/{roomAlias} 

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomAlias	string	Required: The room alias to set. Its format is defined in the appendices.
Request body
Name	Type	Description
room_id	string	Required: The room ID to set.
Request body example
{
  "room_id": "!abnjk1jdasj98:capuchins.com"
}

Responses
Status	Description
200	The mapping was created.
400	The given roomAlias is not a valid room alias.
409	A room alias with that name already exists.
200 response
{}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_INVALID_PARAM",
  "error": "Room alias invalid"
}

409 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN",
  "error": "Room alias #monkeys:matrix.org already exists."
}
DELETE /_matrix/client/v3/directory/room/{roomAlias} 

Remove a mapping of room alias to room ID.

Servers may choose to implement additional access control checks here, for instance that room aliases can only be deleted by their creator or a server administrator.

Note: Servers may choose to update the alt_aliases for the m.room.canonical_alias state event in the room when an alias is removed. Servers which choose to update the canonical alias event are recommended to, in addition to their other relevant permission checks, delete the alias and return a successful response even if the user does not have permission to update the m.room.canonical_alias event.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomAlias	string	Required: The room alias to remove. Its format is defined in the appendices.
Responses
Status	Description
200	The mapping was deleted.
404	There is no mapped room ID for this room alias.
200 response
{}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Room alias #monkeys:example.org not found."
}
GET /_matrix/client/v3/rooms/{roomId}/aliases 

Get a list of aliases maintained by the local server for the given room.

This endpoint can be called by users who are in the room (external users receive an M_FORBIDDEN error response). If the room’s m.room.history_visibility maps to world_readable, any user can call this endpoint.

Servers may choose to implement additional access control checks here, such as allowing server administrators to view aliases regardless of membership.

Note: Clients are recommended not to display this list of aliases prominently as they are not curated, unlike those listed in the m.room.canonical_alias state event.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room ID to find local aliases of.
Responses
Status	Description
200	The list of local aliases for the room.
400	The given roomAlias is not a valid room alias.
403	The user is not permitted to retrieve the list of local aliases for the room.
429	This request was rate-limited.
200 response
Name	Type	Description
aliases	[string]	Required: The server’s local aliases on the room. Can be empty.
{
  "aliases": [
    "#somewhere:example.com",
    "#another:example.com",
    "#hat_trick:example.com"
  ]
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_INVALID_PARAM",
  "error": "Room alias invalid"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You are not a member of the room."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/joined_rooms 

This API returns a list of the user’s current rooms.

Rate-limited:	No
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	A list of the rooms the user is in.
200 response
Name	Type	Description
joined_rooms	[string]	Required: The ID of each room in which the user has joined membership.
{
  "joined_rooms": [
    "!foo:example.com"
  ]
}
POST /_matrix/client/v3/rooms/{roomId}/invite 

Note that there are two forms of this API, which are documented separately. This version of the API requires that the inviter knows the Matrix identifier of the invitee. The other is documented in the third party invites section.

This API invites a user to participate in a particular room. They do not start participating in the room until they actually join the room.

Only users currently in a particular room can invite other users to join that room.

If the user was invited to the room, the homeserver will append a m.room.member event to the room.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room identifier (not alias) to which to invite the user.
Request body
Name	Type	Description
reason	string	Optional reason to be included as the reason on the subsequent membership event.

Added in v1.1


user_id	string	Required: The fully qualified user ID of the invitee.
Request body example
{
  "reason": "Welcome to the team!",
  "user_id": "@cheeky_monkey:matrix.org"
}

Responses
Status	Description
200	The user has been invited to join the room, or was already invited to the room.
400	

The request is invalid. A meaningful errcode and description error text will be returned. Example reasons for rejection include:

The request body is malformed (errcode set to M_BAD_JSON or M_NOT_JSON).

One or more users being invited to the room are residents of a homeserver which does not support the requested room version. The errcode will be M_UNSUPPORTED_ROOM_VERSION in these cases.


403	

You do not have permission to invite the user to the room. A meaningful errcode and description error text will be returned. Example reasons for rejections are:

The invitee has been banned from the room.
The invitee is already a member of the room.
The inviter is not currently in the room.
The inviter’s power level is insufficient to invite users to the room.

429	This request was rate-limited.
200 response
{}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN",
  "error": "An unknown error occurred"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "@cheeky_monkey:matrix.org is banned from the room"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/join/{roomIdOrAlias} 

Note that this API takes either a room ID or alias, unlike /rooms/{roomId}/join.

This API starts a user participating in a particular room, if that user is allowed to participate in that room. After this call, the client is allowed to see all current state events in the room, and all subsequent events associated with the room until the user leaves the room.

After a user has joined a room, the room will appear as an entry in the response of the /initialSync and /sync APIs.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomIdOrAlias	string	Required: The room identifier or alias to join.
query parameters
Name	Type	Description
server_name	[string]	The servers to attempt to join the room through. One of the servers must be participating in the room.
Request body
Name	Type	Description
reason	string	Optional reason to be included as the reason on the subsequent membership event.

Added in v1.1


third_party_signed	Third Party Signed	If a third_party_signed was supplied, the homeserver must verify that it matches a pending m.room.third_party_invite event in the room, and perform key validity checking if required by the event.
Third Party Signed
Name	Type	Description
mxid	string	Required: The Matrix ID of the invitee.
sender	string	Required: The Matrix ID of the user who issued the invite.
signatures	Signatures	Required: A signatures object containing a signature of the entire signed object.
token	string	Required: The state key of the m.third_party_invite event.
Request body example
{
  "reason": "Looking for support",
  "third_party_signed": {
    "mxid": "@bob:example.org",
    "sender": "@alice:example.org",
    "signatures": {
      "example.org": {
        "ed25519:0": "some9signature"
      }
    },
    "token": "random8nonce"
  }
}

Responses
Status	Description
200	

The room has been joined.

The joined room ID must be returned in the room_id field.


403	

You do not have permission to join the room. A meaningful errcode and description error text will be returned. Example reasons for rejection are:

The room is invite-only and the user was not invited.
The user has been banned from the room.
The room is restricted and the user failed to satisfy any of the conditions.

429	This request was rate-limited.
200 response
Name	Type	Description
room_id	string	Required: The joined room ID.
{
  "room_id": "!d41d8cd:matrix.org"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You are not invited to this room."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/rooms/{roomId}/join 

Note that this API requires a room ID, not alias. /join/{roomIdOrAlias} exists if you have a room alias.

This API starts a user participating in a particular room, if that user is allowed to participate in that room. After this call, the client is allowed to see all current state events in the room, and all subsequent events associated with the room until the user leaves the room.

After a user has joined a room, the room will appear as an entry in the response of the /initialSync and /sync APIs.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room identifier (not alias) to join.
Request body
Name	Type	Description
reason	string	Optional reason to be included as the reason on the subsequent membership event.

Added in v1.1


third_party_signed	Third Party Signed	If supplied, the homeserver must verify that it matches a pending m.room.third_party_invite event in the room, and perform key validity checking if required by the event.
Third Party Signed
Name	Type	Description
mxid	string	Required: The Matrix ID of the invitee.
sender	string	Required: The Matrix ID of the user who issued the invite.
signatures	Signatures	Required: A signatures object containing a signature of the entire signed object.
token	string	Required: The state key of the m.third_party_invite event.
Request body example
{
  "reason": "Looking for support",
  "third_party_signed": {
    "mxid": "@bob:example.org",
    "sender": "@alice:example.org",
    "signatures": {
      "example.org": {
        "ed25519:0": "some9signature"
      }
    },
    "token": "random8nonce"
  }
}

Responses
Status	Description
200	

The room has been joined.

The joined room ID must be returned in the room_id field.


403	

You do not have permission to join the room. A meaningful errcode and description error text will be returned. Example reasons for rejection are:

The room is invite-only and the user was not invited.
The user has been banned from the room.
The room is restricted and the user failed to satisfy any of the conditions.

429	This request was rate-limited.
200 response
Name	Type	Description
room_id	string	Required: The joined room ID.
{
  "room_id": "!d41d8cd:matrix.org"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You are not invited to this room."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/knock/{roomIdOrAlias} 

Added in v1.1

Note that this API takes either a room ID or alias, unlike other membership APIs.

This API “knocks” on the room to ask for permission to join, if the user is allowed to knock on the room. Acceptance of the knock happens out of band from this API, meaning that the client will have to watch for updates regarding the acceptance/rejection of the knock.

If the room history settings allow, the user will still be able to see history of the room while being in the “knock” state. The user will have to accept the invitation to join the room (acceptance of knock) to see messages reliably. See the /join endpoints for more information about history visibility to the user.

The knock will appear as an entry in the response of the /sync API.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomIdOrAlias	string	Required: The room identifier or alias to knock upon.
query parameters
Name	Type	Description
server_name	[string]	The servers to attempt to knock on the room through. One of the servers must be participating in the room.
Request body
Name	Type	Description
reason	string	Optional reason to be included as the reason on the subsequent membership event.
Request body example
{
  "reason": "Looking for support"
}

Responses
Status	Description
200	

The room has been knocked upon.

The knocked room ID must be returned in the room_id field.


403	

You do not have permission to knock on the room. A meaningful errcode and description error text will be returned. Example reasons for rejection are:

The room is not set up for knocking.
The user has been banned from the room.

404	The room could not be found or resolved to a room ID.
429	This request was rate-limited.
200 response
Name	Type	Description
room_id	string	Required: The knocked room ID.
{
  "room_id": "!d41d8cd:matrix.org"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You are not allowed to knock on this room."
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "That room does not appear to exist."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/rooms/{roomId}/forget 

This API stops a user remembering about a particular room.

In general, history is a first class citizen in Matrix. After this API is called, however, a user will no longer be able to retrieve history for this room. If all users on a homeserver forget a room, the room is eligible for deletion from that homeserver.

If the user is currently joined to the room, they must leave the room before calling this API.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room identifier to forget.
Responses
Status	Description
200	The room has been forgotten.
400	The user has not left the room
429	This request was rate-limited.
200 response
{}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN",
  "error": "User @example:matrix.org is in room !au1ba7o:matrix.org"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/rooms/{roomId}/leave 

This API stops a user participating in a particular room.

If the user was already in the room, they will no longer be able to see new events in the room. If the room requires an invite to join, they will need to be re-invited before they can re-join.

If the user was invited to the room, but had not joined, this call serves to reject the invite.

The user will still be allowed to retrieve history from the room which they were previously allowed to see.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room identifier to leave.
Request body
Name	Type	Description
reason	string	Optional reason to be included as the reason on the subsequent membership event.

Added in v1.1

Request body example
{
  "reason": "Saying farewell - thanks for the support!"
}

Responses
Status	Description
200	The room has been left.
429	This request was rate-limited.
200 response
{}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/rooms/{roomId}/kick 

Kick a user from the room.

The caller must have the required power level in order to perform this operation.

Kicking a user adjusts the target member’s membership state to be leave with an optional reason. Like with other membership changes, a user can directly adjust the target member’s state by making a request to /rooms/<room id>/state/m.room.member/<user id>.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room identifier (not alias) from which the user should be kicked.
Request body
Name	Type	Description
reason	string	The reason the user has been kicked. This will be supplied as the reason on the target’s updated m.room.member event.
user_id	string	Required: The fully qualified user ID of the user being kicked.
Request body example
{
  "reason": "Telling unfunny jokes",
  "user_id": "@cheeky_monkey:matrix.org"
}

Responses
Status	Description
200	The user has been kicked from the room.
403	

You do not have permission to kick the user from the room. A meaningful errcode and description error text will be returned. Example reasons for rejections are:

The kicker is not currently in the room.
The kickee is not currently in the room.
The kicker’s power level is insufficient to kick users from the room.
200 response
{}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You do not have a high enough power level to kick from this room."
}
POST /_matrix/client/v3/rooms/{roomId}/ban 

Ban a user in the room. If the user is currently in the room, also kick them.

When a user is banned from a room, they may not join it or be invited to it until they are unbanned.

The caller must have the required power level in order to perform this operation.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room identifier (not alias) from which the user should be banned.
Request body
Name	Type	Description
reason	string	The reason the user has been banned. This will be supplied as the reason on the target’s updated m.room.member event.

Added in v1.1


user_id	string	Required: The fully qualified user ID of the user being banned.
Request body example
{
  "reason": "Telling unfunny jokes",
  "user_id": "@cheeky_monkey:matrix.org"
}

Responses
Status	Description
200	The user has been kicked and banned from the room.
403	

You do not have permission to ban the user from the room. A meaningful errcode and description error text will be returned. Example reasons for rejections are:

The banner is not currently in the room.
The banner’s power level is insufficient to ban users from the room.
200 response
{}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You do not have a high enough power level to ban from this room."
}
POST /_matrix/client/v3/rooms/{roomId}/unban 

Unban a user from the room. This allows them to be invited to the room, and join if they would otherwise be allowed to join according to its join rules.

The caller must have the required power level in order to perform this operation.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room identifier (not alias) from which the user should be unbanned.
Request body
Name	Type	Description
reason	string	Optional reason to be included as the reason on the subsequent membership event.

Added in v1.1


user_id	string	Required: The fully qualified user ID of the user being unbanned.
Request body example
{
  "reason": "They've been banned long enough",
  "user_id": "@cheeky_monkey:matrix.org"
}

Responses
Status	Description
200	The user has been unbanned from the room.
403	

You do not have permission to unban the user from the room. A meaningful errcode and description error text will be returned. Example reasons for rejections are:

The unbanner’s power level is insufficient to unban users from the room.
200 response
{}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You do not have a high enough power level to unban from this room."
}
GET /_matrix/client/v3/directory/list/room/{roomId} 

Gets the visibility of a given room on the server’s public room directory.

Rate-limited:	No
Requires authentication:	No
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room ID.
Responses
Status	Description
200	The visibility of the room in the directory
404	The room is not known to the server
200 response
Name	Type	Description
visibility	enum	The visibility of the room in the directory.

One of: [private, public].

{
  "visibility": "public"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Room not found"
}
PUT /_matrix/client/v3/directory/list/room/{roomId} 

Sets the visibility of a given room in the server’s public room directory.

Servers may choose to implement additional access control checks here, for instance that room visibility can only be changed by the room creator or a server administrator.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room ID.
Request body
Name	Type	Description
visibility	enum	The new visibility setting for the room. Defaults to ‘public’.

One of: [private, public].

Request body example
{
  "visibility": "public"
}

Responses
Status	Description
200	The visibility was updated, or no change was needed.
404	The room is not known to the server
200 response
{}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Room not found"
}
GET /_matrix/client/v3/publicRooms 

Lists the public rooms on the server.

This API returns paginated responses. The rooms are ordered by the number of joined members, with the largest rooms first.

Rate-limited:	No
Requires authentication:	No
Request
Request parameters
query parameters
Name	Type	Description
limit	integer	Limit the number of results returned.
server	string	The server to fetch the public room lists from. Defaults to the local server.
since	string	A pagination token from a previous request, allowing clients to get the next (or previous) batch of rooms. The direction of pagination is specified solely by which token is supplied, rather than via an explicit flag.
Responses
Status	Description
200	A list of the rooms on the server.
200 response
Name	Type	Description
chunk	[PublicRoomsChunk]	Required: A paginated chunk of public rooms.
next_batch	string	A pagination token for the response. The absence of this token means there are no more results to fetch and the client should stop paginating.
prev_batch	string	A pagination token that allows fetching previous results. The absence of this token means there are no results before this batch, i.e. this is the first batch.
total_room_count_estimate	integer	An estimate on the total number of public rooms, if the server has an estimate.
PublicRoomsChunk
Name	Type	Description
avatar_url	string	The URL for the room’s avatar, if one is set.
canonical_alias	string	The canonical alias of the room, if any.
guest_can_join	boolean	Required: Whether guest users may join the room and participate in it. If they can, they will be subject to ordinary power level rules like any other user.
join_rule	string	The room’s join rule. When not present, the room is assumed to be public. Note that rooms with invite join rules are not expected here, but rooms with knock rules are given their near-public nature.
name	string	The name of the room, if any.
num_joined_members	integer	Required: The number of members joined to the room.
room_id	string	Required: The ID of the room.
room_type	string	The type of room (from m.room.create), if any.

Added in v1.4


topic	string	The topic of the room, if any.
world_readable	boolean	Required: Whether the room may be viewed by guest users without joining.
{
  "chunk": [
    {
      "avatar_url": "mxc://bleecker.street/CHEDDARandBRIE",
      "guest_can_join": false,
      "join_rule": "public",
      "name": "CHEESE",
      "num_joined_members": 37,
      "room_id": "!ol19s:bleecker.street",
      "room_type": "m.space",
      "topic": "Tasty tasty cheese",
      "world_readable": true
    }
  ],
  "next_batch": "p190q",
  "prev_batch": "p1902",
  "total_room_count_estimate": 115
}
POST /_matrix/client/v3/publicRooms 

Lists the public rooms on the server, with optional filter.

This API returns paginated responses. The rooms are ordered by the number of joined members, with the largest rooms first.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
server	string	The server to fetch the public room lists from. Defaults to the local server.
Request body
Name	Type	Description
filter	Filter	Filter to apply to the results.
include_all_networks	boolean	Whether or not to include all known networks/protocols from application services on the homeserver. Defaults to false.
limit	integer	Limit the number of results returned.
since	string	A pagination token from a previous request, allowing clients to get the next (or previous) batch of rooms. The direction of pagination is specified solely by which token is supplied, rather than via an explicit flag.
third_party_instance_id	string	The specific third party network/protocol to request from the homeserver. Can only be used if include_all_networks is false.
Filter
Name	Type	Description
generic_search_term	string	An optional string to search for in the room metadata, e.g. name, topic, canonical alias, etc.
room_types	[string]	An optional list of room types to search for. To include rooms without a room type, specify null within this list. When not specified, all applicable rooms (regardless of type) are returned.

Added in v1.4

Request body example
{
  "filter": {
    "generic_search_term": "foo",
    "room_types": [
      null,
      "m.space"
    ]
  },
  "include_all_networks": false,
  "limit": 10,
  "third_party_instance_id": "irc"
}

Responses
Status	Description
200	A list of the rooms on the server.
200 response
Name	Type	Description
chunk	[PublicRoomsChunk]	Required: A paginated chunk of public rooms.
next_batch	string	A pagination token for the response. The absence of this token means there are no more results to fetch and the client should stop paginating.
prev_batch	string	A pagination token that allows fetching previous results. The absence of this token means there are no results before this batch, i.e. this is the first batch.
total_room_count_estimate	integer	An estimate on the total number of public rooms, if the server has an estimate.
PublicRoomsChunk
Name	Type	Description
avatar_url	string	The URL for the room’s avatar, if one is set.
canonical_alias	string	The canonical alias of the room, if any.
guest_can_join	boolean	Required: Whether guest users may join the room and participate in it. If they can, they will be subject to ordinary power level rules like any other user.
join_rule	string	The room’s join rule. When not present, the room is assumed to be public. Note that rooms with invite join rules are not expected here, but rooms with knock rules are given their near-public nature.
name	string	The name of the room, if any.
num_joined_members	integer	Required: The number of members joined to the room.
room_id	string	Required: The ID of the room.
room_type	string	The type of room (from m.room.create), if any.

Added in v1.4


topic	string	The topic of the room, if any.
world_readable	boolean	Required: Whether the room may be viewed by guest users without joining.
{
  "chunk": [
    {
      "avatar_url": "mxc://bleecker.street/CHEDDARandBRIE",
      "guest_can_join": false,
      "join_rule": "public",
      "name": "CHEESE",
      "num_joined_members": 37,
      "room_id": "!ol19s:bleecker.street",
      "room_type": "m.space",
      "topic": "Tasty tasty cheese",
      "world_readable": true
    }
  ],
  "next_batch": "p190q",
  "prev_batch": "p1902",
  "total_room_count_estimate": 115
}
POST /_matrix/client/v3/user_directory/search 

Performs a search for users. The homeserver may determine which subset of users are searched, however the homeserver MUST at a minimum consider the users the requesting user shares a room with and those who reside in public rooms (known to the homeserver). The search MUST consider local users to the homeserver, and SHOULD query remote users as part of the search.

The search is performed case-insensitively on user IDs and display names preferably using a collation determined based upon the Accept-Language header provided in the request, if present.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request body
Name	Type	Description
limit	integer	The maximum number of results to return. Defaults to 10.
search_term	string	Required: The term to search for
Request body example
{
  "limit": 10,
  "search_term": "foo"
}

Responses
Status	Description
200	The results of the search.
429	This request was rate-limited.
200 response
Name	Type	Description
limited	boolean	Required: Indicates if the result list has been truncated by the limit.
results	[User]	Required: Ordered by rank and then whether or not profile info is available.
User
Name	Type	Description
avatar_url	string	The avatar url, as an MXC, if one exists.
display_name	string	The display name of the user, if one exists.
user_id	string	Required: The user’s matrix user ID.
{
  "limited": false,
  "results": [
    {
      "avatar_url": "mxc://bar.com/foo",
      "display_name": "Foo",
      "user_id": "@foo:bar.com"
    }
  ]
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/profile/{userId} 

Get the combined profile information for this user. This API may be used to fetch the user’s own profile information or other users; either locally or on remote homeservers. This API may return keys which are not limited to displayname or avatar_url.

Rate-limited:	No
Requires authentication:	No
Request
Request parameters
path parameters
Name	Type	Description
userId	string	Required: The user whose profile information to get.
Responses
Status	Description
200	The profile information for this user.
403	The server is unwilling to disclose whether the user exists and/or has profile information.
404	There is no profile information for this user or this user does not exist.
200 response
Name	Type	Description
avatar_url	string	The user’s avatar URL if they have set one, otherwise not present.
displayname	string	The user’s display name if they have set one, otherwise not present.
{
  "avatar_url": "mxc://matrix.org/SDGdghriugerRg",
  "displayname": "Alice Margatroid"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "Profile lookup over federation is disabled on this homeserver"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Profile not found"
}
GET /_matrix/client/v3/profile/{userId}/avatar_url 

Get the user’s avatar URL. This API may be used to fetch the user’s own avatar URL or to query the URL of other users; either locally or on remote homeservers.

Rate-limited:	No
Requires authentication:	No
Request
Request parameters
path parameters
Name	Type	Description
userId	string	Required: The user whose avatar URL to get.
Responses
Status	Description
200	The avatar URL for this user.
404	There is no avatar URL for this user or this user does not exist.
200 response
Name	Type	Description
avatar_url	string	The user’s avatar URL if they have set one, otherwise not present.
{
  "avatar_url": "mxc://matrix.org/SDGdghriugerRg"
}
PUT /_matrix/client/v3/profile/{userId}/avatar_url 

This API sets the given user’s avatar URL. You must have permission to set this user’s avatar URL, e.g. you need to have their access_token.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
userId	string	Required: The user whose avatar URL to set.
Request body
Name	Type	Description
avatar_url	string	The new avatar URL for this user.
Request body example
{
  "avatar_url": "mxc://matrix.org/wefh34uihSDRGhw34"
}

Responses
Status	Description
200	The avatar URL was set.
429	This request was rate-limited.
200 response
{}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/profile/{userId}/displayname 

Get the user’s display name. This API may be used to fetch the user’s own displayname or to query the name of other users; either locally or on remote homeservers.

Rate-limited:	No
Requires authentication:	No
Request
Request parameters
path parameters
Name	Type	Description
userId	string	Required: The user whose display name to get.
Responses
Status	Description
200	The display name for this user.
404	There is no display name for this user or this user does not exist.
200 response
Name	Type	Description
displayname	string	The user’s display name if they have set one, otherwise not present.
{
  "displayname": "Alice Margatroid"
}
PUT /_matrix/client/v3/profile/{userId}/displayname 

This API sets the given user’s display name. You must have permission to set this user’s display name, e.g. you need to have their access_token.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
userId	string	Required: The user whose display name to set.
Request body
Name	Type	Description
displayname	string	The new display name for this user.
Request body example
{
  "displayname": "Alice Margatroid"
}

Responses
Status	Description
200	The display name was set.
429	This request was rate-limited.
200 response
{}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/voip/turnServer 

This API provides credentials for the client to use when initiating calls.

Rate-limited:	Yes
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	The TURN server credentials.
429	This request was rate-limited.
200 response
Name	Type	Description
password	string	Required: The password to use.
ttl	integer	Required: The time-to-live in seconds
uris	[string]	Required: A list of TURN URIs
username	string	Required: The username to use.
{
  "password": "JlKfBy1QwLrO20385QyAtEyIv0=",
  "ttl": 86400,
  "uris": [
    "turn:turn.example.com:3478?transport=udp",
    "turn:10.20.30.40:3478?transport=tcp",
    "turns:10.20.30.40:443?transport=tcp"
  ],
  "username": "1443779631:@user:example.com"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
PUT /_matrix/client/v3/rooms/{roomId}/typing/{userId} 

This tells the server that the user is typing for the next N milliseconds where N is the value specified in the timeout key. Alternatively, if typing is false, it tells the server that the user has stopped typing.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room in which the user is typing.
userId	string	Required: The user who has started to type.
Request body
Name	Type	Description
timeout	integer	The length of time in milliseconds to mark this user as typing.
typing	boolean	Required: Whether the user is typing or not. If false, the timeout key can be omitted.
Request body example
{
  "timeout": 30000,
  "typing": true
}

Responses
Status	Description
200	The new typing state was set.
429	This request was rate-limited.
200 response
{}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/rooms/{roomId}/receipt/{receiptType}/{eventId} 

This API updates the marker for the given receipt type to the event ID specified.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventId	string	Required: The event ID to acknowledge up to.
receiptType	enum	Required:

The type of receipt to send. This can also be m.fully_read as an alternative to /read_markers.

Note that m.fully_read does not appear under m.receipt: this endpoint effectively calls /read_markers internally when presented with a receipt type of m.fully_read.

One of: [m.read, m.read.private, m.fully_read].



Changed in v1.4: Allow m.read.private receipts and m.fully_read markers to be set.
roomId	string	Required: The room in which to send the event.
Request body
Name	Type	Description
thread_id	string	The root thread event’s ID (or main) for which thread this receipt is intended to be under. If not specified, the read receipt is unthreaded (default).

Added in v1.4

Request body example
{
  "thread_id": "main"
}

Responses
Status	Description
200	The receipt was sent.
400	

The thread_id is invalid in some way. For example:

It is not a string.
It is empty.
It is provided for an incompatible receipt type.
The event_id is not related to the thread_id.

429	This request was rate-limited.
200 response
{}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_INVALID_PARAM",
  "error": "thread_id field must be a non-empty string"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/rooms/{roomId}/read_markers 

Sets the position of the read marker for a given room, and optionally the read receipt’s location.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room ID to set the read marker in for the user.
Request body
Name	Type	Description
m.fully_read	string	The event ID the read marker should be located at. The event MUST belong to the room.

Changed in v1.4: This property is no longer required.
m.read	string	The event ID to set the read receipt location at. This is equivalent to calling /receipt/m.read/$elsewhere:example.org and is provided here to save that extra call.
m.read.private	string	The event ID to set the private read receipt location at. This equivalent to calling /receipt/m.read.private/$elsewhere:example.org and is provided here to save that extra call.

Added in v1.4

Request body example
{
  "m.fully_read": "$somewhere:example.org",
  "m.read": "$elsewhere:example.org",
  "m.read.private": "$elsewhere:example.org"
}

Responses
Status	Description
200	The read marker, and read receipt(s) if provided, have been updated.
429	This request was rate-limited.
200 response
{}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/presence/{userId}/status 

Get the given user’s presence state.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
userId	string	Required: The user whose presence state to get.
Responses
Status	Description
200	The presence state for this user.
403	You are not allowed to see this user’s presence status.
404	There is no presence state for this user. This user may not exist or isn’t exposing presence information to you.
200 response
Name	Type	Description
currently_active	boolean	Whether the user is currently active
last_active_ago	integer	The length of time in milliseconds since an action was performed by this user.
presence	enum	Required: This user’s presence.

One of: [online, offline, unavailable].


status_msg	[string null]	The state message for this user if one was set.
{
  "last_active_ago": 420845,
  "presence": "unavailable"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You are not allowed to see their presence"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN",
  "error": "An unknown error occurred"
}
PUT /_matrix/client/v3/presence/{userId}/status 

This API sets the given user’s presence state. When setting the status, the activity time is updated to reflect that activity; the client does not need to specify the last_active_ago field. You cannot set the presence state of another user.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
userId	string	Required: The user whose presence state to update.
Request body
Name	Type	Description
presence	enum	Required: The new presence state.

One of: [online, offline, unavailable].


status_msg	string	The status message to attach to this state.
Request body example
{
  "presence": "online",
  "status_msg": "I am here."
}

Responses
Status	Description
200	The new presence state was set.
429	This request was rate-limited.
200 response
{}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/media/v3/config 

This endpoint allows clients to retrieve the configuration of the content repository, such as upload limitations. Clients SHOULD use this as a guide when using content repository endpoints. All values are intentionally left optional. Clients SHOULD follow the advice given in the field description when the field is not available.

NOTE: Both clients and server administrators should be aware that proxies between the client and the server may affect the apparent behaviour of content repository APIs, for example, proxies may enforce a lower upload size limit than is advertised by the server on this endpoint.

Rate-limited:	Yes
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	The public content repository configuration for the matrix server.
429	This request was rate-limited.
200 response
Name	Type	Description
m.upload.size	integer	The maximum size an upload can be in bytes. Clients SHOULD use this as a guide when uploading content. If not listed or null, the size limit should be treated as unknown.
{
  "m.upload.size": 50000000
}

429 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN",
  "error": "An unknown error occurred"
}
GET /_matrix/media/v3/download/{serverName}/{mediaId} 

Rate-limited:	Yes
Requires authentication:	No
Request
Request parameters
path parameters
Name	Type	Description
mediaId	string	Required: The media ID from the mxc:// URI (the path component)
serverName	string	Required: The server name from the mxc:// URI (the authoritory component)
query parameters
Name	Type	Description
allow_remote	boolean	Indicates to the server that it should not attempt to fetch the media if it is deemed remote. This is to prevent routing loops where the server contacts itself. Defaults to true if not provided.
Responses
Status	Description
200	The content that was previously uploaded.
429	This request was rate-limited.
502	The content is too large for the server to serve.
200 response
429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}

502 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_TOO_LARGE",
  "error": "Content is too large to serve"
}
GET /_matrix/media/v3/download/{serverName}/{mediaId}/{fileName} 

This will download content from the content repository (same as the previous endpoint) but replace the target file name with the one provided by the caller.

Rate-limited:	Yes
Requires authentication:	No
Request
Request parameters
path parameters
Name	Type	Description
fileName	string	Required: A filename to give in the Content-Disposition header.
mediaId	string	Required: The media ID from the mxc:// URI (the path component)
serverName	string	Required: The server name from the mxc:// URI (the authoritory component)
query parameters
Name	Type	Description
allow_remote	boolean	Indicates to the server that it should not attempt to fetch the media if it is deemed remote. This is to prevent routing loops where the server contacts itself. Defaults to true if not provided.
Responses
Status	Description
200	The content that was previously uploaded.
429	This request was rate-limited.
502	The content is too large for the server to serve.
200 response
429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}

502 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_TOO_LARGE",
  "error": "Content is too large to serve"
}
GET /_matrix/media/v3/preview_url 

Get information about a URL for the client. Typically this is called when a client sees a URL in a message and wants to render a preview for the user.

Note: Clients should consider avoiding this endpoint for URLs posted in encrypted rooms. Encrypted rooms often contain more sensitive information the users do not want to share with the homeserver, and this can mean that the URLs being shared should also not be shared with the homeserver.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
ts	integer	The preferred point in time to return a preview for. The server may return a newer version if it does not have the requested version available.
url	string	Required: The URL to get a preview of.
Responses
Status	Description
200	The OpenGraph data for the URL, which may be empty. Some values are replaced with matrix equivalents if they are provided in the response. The differences from the OpenGraph protocol are described here.
429	This request was rate-limited.
200 response
Name	Type	Description
matrix:image:size	integer	The byte-size of the image. Omitted if there is no image attached.
og:image	string	An MXC URI to the image. Omitted if there is no image.
{
  "matrix:image:size": 102400,
  "og:description": "This is a really cool blog post from matrix.org",
  "og:image": "mxc://example.com/ascERGshawAWawugaAcauga",
  "og:image:height": 48,
  "og:image:type": "image/png",
  "og:image:width": 48,
  "og:title": "Matrix Blog Post"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/media/v3/thumbnail/{serverName}/{mediaId} 

Download a thumbnail of content from the content repository. See the Thumbnails section for more information.

Rate-limited:	Yes
Requires authentication:	No
Request
Request parameters
path parameters
Name	Type	Description
mediaId	string	Required: The media ID from the mxc:// URI (the path component)
serverName	string	Required: The server name from the mxc:// URI (the authoritory component)
query parameters
Name	Type	Description
allow_remote	boolean	Indicates to the server that it should not attempt to fetch the media if it is deemed remote. This is to prevent routing loops where the server contacts itself. Defaults to true if not provided.
height	integer	Required: The desired height of the thumbnail. The actual thumbnail may be larger than the size specified.
method	enum	The desired resizing method. See the Thumbnails section for more information.

One of: [crop, scale].


width	integer	Required: The desired width of the thumbnail. The actual thumbnail may be larger than the size specified.
Responses
Status	Description
200	A thumbnail of the requested content.
400	The request does not make sense to the server, or the server cannot thumbnail the content. For example, the client requested non-integer dimensions or asked for negatively-sized images.
413	The local content is too large for the server to thumbnail.
429	This request was rate-limited.
502	The remote content is too large for the server to thumbnail.
200 response
400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN",
  "error": "Cannot generate thumbnails for the requested content"
}

413 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_TOO_LARGE",
  "error": "Content is too large to thumbnail"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}

502 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_TOO_LARGE",
  "error": "Content is too large to thumbnail"
}
POST /_matrix/media/v3/upload 

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
header parameters
Name	Type	Description
Content-Type	string	The content type of the file being uploaded
query parameters
Name	Type	Description
filename	string	The name of the file being uploaded
Request body
Request body example
"<bytes>"

Responses
Status	Description
200	The MXC URI for the uploaded content.
403	

The user does not have permission to upload the content. Some reasons for this error include:

The server does not permit the file type.
The user has reached a quota for uploaded content.

413	The uploaded content is too large for the server.
429	This request was rate-limited.
200 response
Name	Type	Description
content_uri	string	Required: The MXC URI to the uploaded content.
{
  "content_uri": "mxc://example.com/AQwafuaFswefuhsfAFAgsw"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "Cannot upload this content"
}

413 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_TOO_LARGE",
  "error": "Cannot upload files larger than 100mb"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
PUT /_matrix/client/v3/sendToDevice/{eventType}/{txnId} 

This endpoint is used to send send-to-device events to a set of client devices.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventType	string	Required: The type of event to send.
txnId	string	Required: The transaction ID for this event. Clients should generate an ID unique across requests with the same access token; it will be used by the server to ensure idempotency of requests.
Request body
body
Name	Type	Description
messages	object	Required: The messages to send. A map from user ID, to a map from device ID to message body. The device ID may also be *, meaning all known devices for the user.
Request body example
{
  "messages": {
    "@alice:example.com": {
      "TLLBEANAAG": {
        "example_content_key": "value"
      }
    }
  }
}

Responses
Status	Description
200	The message was successfully sent.
200 response
{}
POST /_matrix/client/v3/delete_devices 

This API endpoint uses the User-Interactive Authentication API.

Deletes the given devices, and invalidates any access token associated with them.

Rate-limited:	No
Requires authentication:	Yes
Request
Request body
Name	Type	Description
auth	Authentication Data	Additional authentication information for the user-interactive authentication API.
devices	[string]	Required: The list of device IDs to delete.
Authentication Data
Name	Type	Description
session	string	The value of the session key given by the homeserver.
type	string	The authentication type that the client is attempting to complete. May be omitted if session is given, and the client is reissuing a request which it believes has been completed out-of-band (for example, via the fallback mechanism).
Request body example
{
  "auth": {
    "example_credential": "verypoorsharedsecret",
    "session": "xxxxx",
    "type": "example.type.foo"
  },
  "devices": [
    "QBUAZIFURK",
    "AUIECTSRND"
  ]
}

Responses
Status	Description
200	The devices were successfully removed, or had been removed previously.
401	The homeserver requires additional authentication information.
200 response
{}

401 response
Authentication response
Name	Type	Description
completed	[string]	A list of the stages the client has completed successfully
flows	[Flow information]	Required: A list of the login flows supported by the server for this API.
params	object	Contains any information that the client will need to know in order to use a given type of authentication. For each login type presented, that type may be present as a key in this dictionary. For example, the public part of an OAuth client ID could be given here.
session	string	This is a session identifier that the client must pass back to the home server, if one is provided, in subsequent attempts to authenticate in the same API call.
Flow information
Name	Type	Description
stages	[string]	Required: The login type of each of the stages required to complete this authentication flow
{
  "completed": [
    "example.type.foo"
  ],
  "flows": [
    {
      "stages": [
        "example.type.foo"
      ]
    }
  ],
  "params": {
    "example.type.baz": {
      "example_key": "foobar"
    }
  },
  "session": "xxxxxxyz"
}
GET /_matrix/client/v3/devices 

Gets information about all devices for the current user.

Rate-limited:	No
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	Device information
200 response
Name	Type	Description
devices	[Device]	A list of all registered devices for this user.
Device
Name	Type	Description
device_id	string	Required: Identifier of this device.
display_name	string	Display name set by the user for this device. Absent if no name has been set.
last_seen_ip	string	The IP address where this device was last seen. (May be a few minutes out of date, for efficiency reasons).
last_seen_ts	integer	The timestamp (in milliseconds since the unix epoch) when this devices was last seen. (May be a few minutes out of date, for efficiency reasons).
{
  "devices": [
    {
      "device_id": "QBUAZIFURK",
      "display_name": "android",
      "last_seen_ip": "1.2.3.4",
      "last_seen_ts": 1474491775024
    }
  ]
}
GET /_matrix/client/v3/devices/{deviceId} 

Gets information on a single device, by device id.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
deviceId	string	Required: The device to retrieve.
Responses
Status	Description
200	Device information
404	The current user has no device with the given ID.
200 response
Device
Name	Type	Description
device_id	string	Required: Identifier of this device.
display_name	string	Display name set by the user for this device. Absent if no name has been set.
last_seen_ip	string	The IP address where this device was last seen. (May be a few minutes out of date, for efficiency reasons).
last_seen_ts	integer	The timestamp (in milliseconds since the unix epoch) when this devices was last seen. (May be a few minutes out of date, for efficiency reasons).
{
  "device_id": "QBUAZIFURK",
  "display_name": "android",
  "last_seen_ip": "1.2.3.4",
  "last_seen_ts": 1474491775024
}
PUT /_matrix/client/v3/devices/{deviceId} 

Updates the metadata on the given device.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
deviceId	string	Required: The device to update.
Request body
Name	Type	Description
display_name	string	The new display name for this device. If not given, the display name is unchanged.
Request body example
{
  "display_name": "My other phone"
}

Responses
Status	Description
200	The device was successfully updated.
404	The current user has no device with the given ID.
200 response
{}
DELETE /_matrix/client/v3/devices/{deviceId} 

This API endpoint uses the User-Interactive Authentication API.

Deletes the given device, and invalidates any access token associated with it.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
deviceId	string	Required: The device to delete.
Request body
Name	Type	Description
auth	Authentication Data	Additional authentication information for the user-interactive authentication API.
Authentication Data
Name	Type	Description
session	string	The value of the session key given by the homeserver.
type	string	The authentication type that the client is attempting to complete. May be omitted if session is given, and the client is reissuing a request which it believes has been completed out-of-band (for example, via the fallback mechanism).
Request body example
{
  "auth": {
    "example_credential": "verypoorsharedsecret",
    "session": "xxxxx",
    "type": "example.type.foo"
  }
}

Responses
Status	Description
200	The device was successfully removed, or had been removed previously.
401	The homeserver requires additional authentication information.
200 response
{}

401 response
Authentication response
Name	Type	Description
completed	[string]	A list of the stages the client has completed successfully
flows	[Flow information]	Required: A list of the login flows supported by the server for this API.
params	object	Contains any information that the client will need to know in order to use a given type of authentication. For each login type presented, that type may be present as a key in this dictionary. For example, the public part of an OAuth client ID could be given here.
session	string	This is a session identifier that the client must pass back to the home server, if one is provided, in subsequent attempts to authenticate in the same API call.
Flow information
Name	Type	Description
stages	[string]	Required: The login type of each of the stages required to complete this authentication flow
{
  "completed": [
    "example.type.foo"
  ],
  "flows": [
    {
      "stages": [
        "example.type.foo"
      ]
    }
  ],
  "params": {
    "example.type.baz": {
      "example_key": "foobar"
    }
  },
  "session": "xxxxxxyz"
}
POST /_matrix/client/v3/keys/device_signing/upload 

Added in v1.1

Publishes cross-signing keys for the user.

This API endpoint uses the User-Interactive Authentication API.

Rate-limited:	No
Requires authentication:	Yes
Request
Request body
Name	Type	Description
auth	Authentication Data	Additional authentication information for the user-interactive authentication API.
master_key	CrossSigningKey	Optional. The user's master key.
self_signing_key	CrossSigningKey	Optional. The user's self-signing key. Must be signed by the accompanying master key, or by the user's most recently uploaded master key if no master key is included in the request.
user_signing_key	CrossSigningKey	Optional. The user's user-signing key. Must be signed by the accompanying master key, or by the user's most recently uploaded master key if no master key is included in the request.
Authentication Data
Name	Type	Description
session	string	The value of the session key given by the homeserver.
type	string	The authentication type that the client is attempting to complete. May be omitted if session is given, and the client is reissuing a request which it believes has been completed out-of-band (for example, via the fallback mechanism).
CrossSigningKey
Name	Type	Description
keys	object	Required: The public key. The object must have exactly one property, whose name is in the form <algorithm>:<unpadded_base64_public_key>, and whose value is the unpadded base64 public key.
signatures	Signatures	Signatures of the key, calculated using the process described at Signing JSON. Optional for the master key. Other keys must be signed by the user's master key.
usage	[string]	Required: What the key is used for.
user_id	string	Required: The ID of the user the key belongs to.
Request body example
{
  "auth": {
    "example_credential": "verypoorsharedsecret",
    "session": "xxxxx",
    "type": "example.type.foo"
  },
  "master_key": {
    "keys": {
      "ed25519:base64+master+public+key": "base64+master+public+key"
    },
    "usage": [
      "master"
    ],
    "user_id": "@alice:example.com"
  },
  "self_signing_key": {
    "keys": {
      "ed25519:base64+self+signing+public+key": "base64+self+signing+master+public+key"
    },
    "signatures": {
      "@alice:example.com": {
        "ed25519:base64+master+public+key": "signature+of+self+signing+key"
      }
    },
    "usage": [
      "self_signing"
    ],
    "user_id": "@alice:example.com"
  },
  "user_signing_key": {
    "keys": {
      "ed25519:base64+user+signing+public+key": "base64+user+signing+master+public+key"
    },
    "signatures": {
      "@alice:example.com": {
        "ed25519:base64+master+public+key": "signature+of+user+signing+key"
      }
    },
    "usage": [
      "user_signing"
    ],
    "user_id": "@alice:example.com"
  }
}

Responses
Status	Description
200	The provided keys were successfully uploaded.
400	

The input was invalid in some way. This can include one of the following error codes:

M_INVALID_SIGNATURE: For example, the self-signing or user-signing key had an incorrect signature.
M_MISSING_PARAM: No master key is available.

403	The public key of one of the keys is the same as one of the user's device IDs, or the request is not authorized for any other reason.
200 response
{}

400 response
{
  "errcode": "M_INVALID_SIGNATURE",
  "error": "Invalid signature"
}

403 response
{
  "errcode": "M_FORBIDDEN",
  "error": "Key ID in use"
}
POST /_matrix/client/v3/keys/signatures/upload 

Added in v1.1

Publishes cross-signing signatures for the user. The request body is a map from user ID to key ID to signed JSON object.

Rate-limited:	No
Requires authentication:	Yes
Request
Request body
Request body example
{
  "@alice:example.com": {
    "HIJKLMN": {
      "algorithms": [
        "m.olm.v1.curve25519-aes-sha256",
        "m.megolm.v1.aes-sha"
      ],
      "device_id": "HIJKLMN",
      "keys": {
        "curve25519:HIJKLMN": "base64+curve25519+key",
        "ed25519:HIJKLMN": "base64+ed25519+key"
      },
      "signatures": {
        "@alice:example.com": {
          "ed25519:base64+self+signing+public+key": "base64+signature+of+HIJKLMN"
        }
      },
      "user_id": "@alice:example.com"
    },
    "base64+master+public+key": {
      "keys": {
        "ed25519:base64+master+public+key": "base64+master+public+key"
      },
      "signatures": {
        "@alice:example.com": {
          "ed25519:HIJKLMN": "base64+signature+of+master+key"
        }
      },
      "usage": [
        "master"
      ],
      "user_id": "@alice:example.com"
    }
  },
  "@bob:example.com": {
    "bobs+base64+master+public+key": {
      "keys": {
        "ed25519:bobs+base64+master+public+key": "bobs+base64+master+public+key"
      },
      "signatures": {
        "@alice:example.com": {
          "ed25519:base64+user+signing+public+key": "base64+signature+of+bobs+master+key"
        }
      },
      "usage": [
        "master"
      ],
      "user_id": "@bob:example.com"
    }
  }
}

Responses
Status	Description
200	The provided signatures were processed.
200 response
Name	Type	Description
failures	object	A map from user ID to key ID to an error for any signatures that failed. If a signature was invalid, the errcode will be set to M_INVALID_SIGNATURE.
{
  "failures": {
    "@alice:example.com": {
      "HIJKLMN": {
        "errcode": "M_INVALID_SIGNATURE",
        "error": "Invalid signature"
      }
    }
  }
}
GET /_matrix/client/v3/room_keys/keys 

Added in v1.1

Retrieve the keys from the backup.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
version	string	Required: The backup from which to retrieve the keys.
Responses
Status	Description
200	The key data. If no keys are found, then an object with an empty rooms property will be returned ({"rooms": {}}).
404	The backup was not found.
429	This request was rate-limited.
200 response
Name	Type	Description
rooms	object	Required: A map of room IDs to room key backup data.
{
  "rooms": {
    "!room:example.org": {
      "sessions": {
        "sessionid1": {
          "first_message_index": 1,
          "forwarded_count": 0,
          "is_verified": true,
          "session_data": {
            "ciphertext": "base64+ciphertext+of+JSON+data",
            "ephemeral": "base64+ephemeral+key",
            "mac": "base64+mac+of+ciphertext"
          }
        }
      }
    }
  }
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unknown backup version."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
PUT /_matrix/client/v3/room_keys/keys 

Added in v1.1

Store several keys in the backup.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
version	string	Required: The backup in which to store the keys. Must be the current backup.
Request body
Name	Type	Description
rooms	object	Required: A map of room IDs to room key backup data.
Request body example
{
  "rooms": {
    "!room:example.org": {
      "sessions": {
        "sessionid1": {
          "first_message_index": 1,
          "forwarded_count": 0,
          "is_verified": true,
          "session_data": {
            "ciphertext": "base64+ciphertext+of+JSON+data",
            "ephemeral": "base64+ephemeral+key",
            "mac": "base64+mac+of+ciphertext"
          }
        }
      }
    }
  }
}

Responses
Status	Description
200	The update succeeded
403	The version specified does not match the current backup version. The current version will be included in the current_version field.
404	The backup was not found.
429	This request was rate-limited.
200 response
RoomKeysUpdateResponse
Name	Type	Description
count	integer	Required: The number of keys stored in the backup
etag	string	Required: The new etag value representing stored keys in the backup. See GET /room_keys/version/{version} for more details.
{
  "count": 10,
  "etag": "abcdefg"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "current_version": "42",
  "errcode": "M_WRONG_ROOM_KEYS_VERSION",
  "error": "Wrong backup version."
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unknown backup version"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
DELETE /_matrix/client/v3/room_keys/keys 

Added in v1.1

Delete the keys from the backup.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
version	string	Required: The backup from which to delete the key
Responses
Status	Description
200	The update succeeded
404	The backup was not found.
429	This request was rate-limited.
200 response
RoomKeysUpdateResponse
Name	Type	Description
count	integer	Required: The number of keys stored in the backup
etag	string	Required: The new etag value representing stored keys in the backup. See GET /room_keys/version/{version} for more details.
{
  "count": 10,
  "etag": "abcdefg"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unknown backup version"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/room_keys/keys/{roomId} 

Added in v1.1

Retrieve the keys from the backup for a given room.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room that the requested key is for.
query parameters
Name	Type	Description
version	string	Required: The backup from which to retrieve the key.
Responses
Status	Description
200	The key data. If no keys are found, then an object with an empty sessions property will be returned ({"sessions": {}}).
404	The backup was not found.
429	This request was rate-limited.
200 response
RoomKeyBackup
Name	Type	Description
sessions	object	Required: A map of session IDs to key data.
{
  "sessions": {
    "sessionid1": {
      "first_message_index": 1,
      "forwarded_count": 0,
      "is_verified": true,
      "session_data": {
        "ciphertext": "base64+ciphertext+of+JSON+data",
        "ephemeral": "base64+ephemeral+key",
        "mac": "base64+mac+of+ciphertext"
      }
    }
  }
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unknown backup version"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
PUT /_matrix/client/v3/room_keys/keys/{roomId} 

Added in v1.1

Store several keys in the backup for a given room.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room that the keys are for.
query parameters
Name	Type	Description
version	string	Required: The backup in which to store the keys. Must be the current backup.
Request body
RoomKeyBackup
Name	Type	Description
sessions	object	Required: A map of session IDs to key data.
Request body example
{
  "sessions": {
    "sessionid1": {
      "first_message_index": 1,
      "forwarded_count": 0,
      "is_verified": true,
      "session_data": {
        "ciphertext": "base64+ciphertext+of+JSON+data",
        "ephemeral": "base64+ephemeral+key",
        "mac": "base64+mac+of+ciphertext"
      }
    }
  }
}

Responses
Status	Description
200	The update succeeded
403	The version specified does not match the current backup version. The current version will be included in the current_version field.
404	The backup was not found.
429	This request was rate-limited.
200 response
RoomKeysUpdateResponse
Name	Type	Description
count	integer	Required: The number of keys stored in the backup
etag	string	Required: The new etag value representing stored keys in the backup. See GET /room_keys/version/{version} for more details.
{
  "count": 10,
  "etag": "abcdefg"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "current_version": "42",
  "errcode": "M_WRONG_ROOM_KEYS_VERSION",
  "error": "Wrong backup version."
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unknown backup version"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
DELETE /_matrix/client/v3/room_keys/keys/{roomId} 

Added in v1.1

Delete the keys from the backup for a given room.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room that the specified key is for.
query parameters
Name	Type	Description
version	string	Required: The backup from which to delete the key.
Responses
Status	Description
200	The update succeeded
404	The backup was not found.
429	This request was rate-limited.
200 response
RoomKeysUpdateResponse
Name	Type	Description
count	integer	Required: The number of keys stored in the backup
etag	string	Required: The new etag value representing stored keys in the backup. See GET /room_keys/version/{version} for more details.
{
  "count": 10,
  "etag": "abcdefg"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unknown backup version"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/room_keys/keys/{roomId}/{sessionId} 

Added in v1.1

Retrieve a key from the backup.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room that the requested key is for.
sessionId	string	Required: The ID of the megolm session whose key is requested.
query parameters
Name	Type	Description
version	string	Required: The backup from which to retrieve the key.
Responses
Status	Description
200	The key data
404	The key or backup was not found.
429	This request was rate-limited.
200 response
KeyBackupData
Name	Type	Description
first_message_index	integer	Required: The index of the first message in the session that the key can decrypt.
forwarded_count	integer	Required: The number of times this key has been forwarded via key-sharing between devices.
is_verified	boolean	Required: Whether the device backing up the key verified the device that the key is from.
session_data	object	Required: Algorithm-dependent data. See the documentation for the backup algorithms in Server-side key backups for more information on the expected format of the data.
{
  "first_message_index": 1,
  "session_data": {
    "ciphertext": "base64+ciphertext+of+JSON+data",
    "ephemeral": "base64+ephemeral+key",
    "mac": "base64+mac+of+ciphertext"
  }
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Key not found."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
PUT /_matrix/client/v3/room_keys/keys/{roomId}/{sessionId} 

Added in v1.1

Store a key in the backup.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room that the key is for.
sessionId	string	Required: The ID of the megolm session that the key is for.
query parameters
Name	Type	Description
version	string	Required: The backup in which to store the key. Must be the current backup.
Request body
KeyBackupData
Name	Type	Description
first_message_index	integer	Required: The index of the first message in the session that the key can decrypt.
forwarded_count	integer	Required: The number of times this key has been forwarded via key-sharing between devices.
is_verified	boolean	Required: Whether the device backing up the key verified the device that the key is from.
session_data	object	Required: Algorithm-dependent data. See the documentation for the backup algorithms in Server-side key backups for more information on the expected format of the data.
Request body example
{
  "first_message_index": 1,
  "session_data": {
    "ciphertext": "base64+ciphertext+of+JSON+data",
    "ephemeral": "base64+ephemeral+key",
    "mac": "base64+mac+of+ciphertext"
  }
}

Responses
Status	Description
200	The update succeeded.
403	The version specified does not match the current backup version. The current version will be included in the current_version field.
429	This request was rate-limited.
200 response
RoomKeysUpdateResponse
Name	Type	Description
count	integer	Required: The number of keys stored in the backup
etag	string	Required: The new etag value representing stored keys in the backup. See GET /room_keys/version/{version} for more details.
{
  "count": 10,
  "etag": "abcdefg"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "current_version": "42",
  "errcode": "M_WRONG_ROOM_KEYS_VERSION",
  "error": "Wrong backup version."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
DELETE /_matrix/client/v3/room_keys/keys/{roomId}/{sessionId} 

Added in v1.1

Delete a key from the backup.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room that the specified key is for.
sessionId	string	Required: The ID of the megolm session whose key is to be deleted.
query parameters
Name	Type	Description
version	string	Required: The backup from which to delete the key
Responses
Status	Description
200	The update succeeded
404	The backup was not found.
429	This request was rate-limited.
200 response
RoomKeysUpdateResponse
Name	Type	Description
count	integer	Required: The number of keys stored in the backup
etag	string	Required: The new etag value representing stored keys in the backup. See GET /room_keys/version/{version} for more details.
{
  "count": 10,
  "etag": "abcdefg"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unknown backup version"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/room_keys/version 

Added in v1.1

Get information about the latest backup version.

Rate-limited:	Yes
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	The information about the backup.
404	No backup exists.
429	This request was rate-limited.
200 response
Name	Type	Description
algorithm	enum	Required: The algorithm used for storing backups.

One of: [m.megolm_backup.v1.curve25519-aes-sha2].


auth_data	object	Required: Algorithm-dependent data. See the documentation for the backup algorithms in Server-side key backups for more information on the expected format of the data.
count	integer	Required: The number of keys stored in the backup.
etag	string	Required: An opaque string representing stored keys in the backup. Clients can compare it with the etag value they received in the request of their last key storage request. If not equal, another client has modified the backup.
version	string	Required: The backup version.
{
  "algorithm": "m.megolm_backup.v1.curve25519-aes-sha2",
  "auth_data": {
    "public_key": "abcdefg",
    "signatures": {
      "@alice:example.org": {
        "ed25519:deviceid": "signature"
      }
    }
  },
  "count": 42,
  "etag": "anopaquestring",
  "version": "1"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "No current backup version"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/room_keys/version 

Added in v1.1

Creates a new backup.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request body
Name	Type	Description
algorithm	enum	Required: The algorithm used for storing backups.

One of: [m.megolm_backup.v1.curve25519-aes-sha2].


auth_data	object	Required: Algorithm-dependent data. See the documentation for the backup algorithms in Server-side key backups for more information on the expected format of the data.
Request body example
{
  "algorithm": "m.megolm_backup.v1.curve25519-aes-sha2",
  "auth_data": {
    "public_key": "abcdefg",
    "signatures": {
      "@alice:example.org": {
        "ed25519:deviceid": "signature"
      }
    }
  }
}

Responses
Status	Description
200	The version id of the new backup.
429	This request was rate-limited.
200 response
Name	Type	Description
version	string	Required: The backup version. This is an opaque string.
{
  "version": "1"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/room_keys/version/{version} 

Added in v1.1

Get information about an existing backup.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
version	string	Required: The backup version to get, as returned in the version parameter of the response in POST /_matrix/client/v3/room_keys/version or this endpoint.
Responses
Status	Description
200	The information about the requested backup.
404	The backup specified does not exist.
429	This request was rate-limited.
200 response
Name	Type	Description
algorithm	enum	Required: The algorithm used for storing backups.

One of: [m.megolm_backup.v1.curve25519-aes-sha2].


auth_data	object	Required: Algorithm-dependent data. See the documentation for the backup algorithms in Server-side key backups for more information on the expected format of the data.
count	integer	Required: The number of keys stored in the backup.
etag	string	Required: An opaque string representing stored keys in the backup. Clients can compare it with the etag value they received in the request of their last key storage request. If not equal, another client has modified the backup.
version	string	Required: The backup version.
{
  "algorithm": "m.megolm_backup.v1.curve25519-aes-sha2",
  "auth_data": {
    "public_key": "abcdefg",
    "signatures": {
      "@alice:example.org": {
        "ed25519:deviceid": "signature"
      }
    }
  },
  "count": 42,
  "etag": "anopaquestring",
  "version": "1"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unknown backup version"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
PUT /_matrix/client/v3/room_keys/version/{version} 

Added in v1.1

Update information about an existing backup. Only auth_data can be modified.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
version	string	Required: The backup version to update, as returned in the version parameter in the response of POST /_matrix/client/v3/room_keys/version or GET /_matrix/client/v3/room_keys/version/{version}.
Request body
Name	Type	Description
algorithm	enum	Required: The algorithm used for storing backups. Must be the same as the algorithm currently used by the backup.

One of: [m.megolm_backup.v1.curve25519-aes-sha2].


auth_data	object	Required: Algorithm-dependent data. See the documentation for the backup algorithms in Server-side key backups for more information on the expected format of the data.
version	string	The backup version. If present, must be the same as the version in the path parameter.
Request body example
{
  "algorithm": "m.megolm_backup.v1.curve25519-aes-sha2",
  "auth_data": {
    "public_key": "abcdefg",
    "signatures": {
      "@alice:example.org": {
        "ed25519:deviceid": "signature"
      }
    }
  },
  "version": "1"
}

Responses
Status	Description
200	The update succeeded.
400	A parameter was incorrect. For example, the algorithm does not match the current backup algorithm, or the version in the body does not match the version in the path.
404	The backup specified does not exist.
429	This request was rate-limited.
200 response
{}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_INVALID_PARAM",
  "error": "Algorithm does not match"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unknown backup version"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
DELETE /_matrix/client/v3/room_keys/version/{version} 

Added in v1.1

Delete an existing key backup. Both the information about the backup, as well as all key data related to the backup will be deleted.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
version	string	Required: The backup version to delete, as returned in the version parameter in the response of POST /_matrix/client/v3/room_keys/version or GET /_matrix/client/v3/room_keys/version/{version}.
Responses
Status	Description
200	The delete succeeded, or the specified backup was previously deleted.
404	The backup specified does not exist. If the backup was previously deleted, the call should succeed rather than returning an error.
429	This request was rate-limited.
200 response
{}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Unknown backup version"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/keys/changes 

Gets a list of users who have updated their device identity keys since a previous sync token.

The server should include in the results any users who:

currently share a room with the calling user (ie, both users have membership state join); and
added new device identity keys or removed an existing device with identity keys, between from and to.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
from	string	Required: The desired start point of the list. Should be the next_batch field from a response to an earlier call to /sync. Users who have not uploaded new device identity keys since this point, nor deleted existing devices with identity keys since then, will be excluded from the results.
to	string	Required: The desired end point of the list. Should be the next_batch field from a recent call to /sync - typically the most recent such call. This may be used by the server as a hint to check its caches are up to date.
Responses
Status	Description
200	The list of users who updated their devices.
200 response
Name	Type	Description
changed	[string]	The Matrix User IDs of all users who updated their device identity keys.
left	[string]	The Matrix User IDs of all users who may have left all the end-to-end encrypted rooms they previously shared with the user.
{
  "changed": [
    "@alice:example.com",
    "@bob:example.org"
  ],
  "left": [
    "@clara:example.com",
    "@doug:example.org"
  ]
}
POST /_matrix/client/v3/keys/claim 

Claims one-time keys for use in pre-key messages.

Rate-limited:	No
Requires authentication:	Yes
Request
Request body
Name	Type	Description
one_time_keys	object	Required: The keys to be claimed. A map from user ID, to a map from device ID to algorithm name.
timeout	integer	The time (in milliseconds) to wait when downloading keys from remote servers. 10 seconds is the recommended default.
Request body example
{
  "one_time_keys": {
    "@alice:example.com": {
      "JLAFKJWSCS": "signed_curve25519"
    }
  },
  "timeout": 10000
}

Responses
Status	Description
200	The claimed keys.
200 response
Name	Type	Description
failures	object	

If any remote homeservers could not be reached, they are recorded here. The names of the properties are the names of the unreachable servers.

If the homeserver could be reached, but the user or device was unknown, no failure is recorded. Instead, the corresponding user or device is missing from the one_time_keys result.


one_time_keys	object	Required:

One-time keys for the queried devices. A map from user ID, to a map from devices to a map from <algorithm>:<key_id> to the key object.

See the key algorithms section for information on the Key Object format.

If necessary, the claimed key might be a fallback key. Fallback keys are re-used by the server until replaced by the device.

{
  "one_time_keys": {
    "@alice:example.com": {
      "JLAFKJWSCS": {
        "signed_curve25519:AAAAHg": {
          "key": "zKbLg+NrIjpnagy+pIY6uPL4ZwEG2v+8F9lmgsnlZzs",
          "signatures": {
            "@alice:example.com": {
              "ed25519:JLAFKJWSCS": "FLWxXqGbwrb8SM3Y795eB6OA8bwBcoMZFXBqnTn58AYWZSqiD45tlBVcDa2L7RwdKXebW/VzDlnfVJ+9jok1Bw"
            }
          }
        }
      }
    }
  }
}
POST /_matrix/client/v3/keys/query 

Returns the current devices and identity keys for the given users.

Rate-limited:	No
Requires authentication:	Yes
Request
Request body
Name	Type	Description
device_keys	object	Required: The keys to be downloaded. A map from user ID, to a list of device IDs, or to an empty list to indicate all devices for the corresponding user.
timeout	integer	The time (in milliseconds) to wait when downloading keys from remote servers. 10 seconds is the recommended default.
token	string	If the client is fetching keys as a result of a device update received in a sync request, this should be the ‘since’ token of that sync request, or any later sync token. This allows the server to ensure its response contains the keys advertised by the notification in that sync.
Request body example
{
  "device_keys": {
    "@alice:example.com": []
  },
  "timeout": 10000
}

Responses
Status	Description
200	The device information
200 response
Name	Type	Description
device_keys	object	Information on the queried devices. A map from user ID, to a map from device ID to device information. For each device, the information returned will be the same as uploaded via /keys/upload, with the addition of an unsigned property.
failures	object	

If any remote homeservers could not be reached, they are recorded here. The names of the properties are the names of the unreachable servers.

If the homeserver could be reached, but the user or device was unknown, no failure is recorded. Instead, the corresponding user or device is missing from the device_keys result.


master_keys	object	Information on the master cross-signing keys of the queried users. A map from user ID, to master key information. For each key, the information returned will be the same as uploaded via /keys/device_signing/upload, along with the signatures uploaded via /keys/signatures/upload that the requesting user is allowed to see.

Added in v1.1


self_signing_keys	object	Information on the self-signing keys of the queried users. A map from user ID, to self-signing key information. For each key, the information returned will be the same as uploaded via /keys/device_signing/upload.

Added in v1.1


user_signing_keys	object	Information on the user-signing key of the user making the request, if they queried their own device information. A map from user ID, to user-signing key information. The information returned will be the same as uploaded via /keys/device_signing/upload.
{
  "device_keys": {
    "@alice:example.com": {
      "JLAFKJWSCS": {
        "algorithms": [
          "m.olm.v1.curve25519-aes-sha2",
          "m.megolm.v1.aes-sha2"
        ],
        "device_id": "JLAFKJWSCS",
        "keys": {
          "curve25519:JLAFKJWSCS": "3C5BFWi2Y8MaVvjM8M22DBmh24PmgR0nPvJOIArzgyI",
          "ed25519:JLAFKJWSCS": "lEuiRJBit0IG6nUf5pUzWTUEsRVVe/HJkoKuEww9ULI"
        },
        "signatures": {
          "@alice:example.com": {
            "ed25519:JLAFKJWSCS": "dSO80A01XiigH3uBiDVx/EjzaoycHcjq9lfQX0uWsqxl2giMIiSPR8a4d291W1ihKJL/a+myXS367WT6NAIcBA"
          }
        },
        "unsigned": {
          "device_display_name": "Alice's mobile phone"
        },
        "user_id": "@alice:example.com"
      }
    }
  },
  "master_keys": {
    "@alice:example.com": {
      "keys": {
        "ed25519:base64+master+public+key": "base64+master+public+key"
      },
      "usage": [
        "master"
      ],
      "user_id": "@alice:example.com"
    }
  },
  "self_signing_keys": {
    "@alice:example.com": {
      "keys": {
        "ed25519:base64+self+signing+public+key": "base64+self+signing+master+public+key"
      },
      "signatures": {
        "@alice:example.com": {
          "ed25519:base64+master+public+key": "signature+of+self+signing+key"
        }
      },
      "usage": [
        "self_signing"
      ],
      "user_id": "@alice:example.com"
    }
  },
  "user_signing_keys": {
    "@alice:example.com": {
      "keys": {
        "ed25519:base64+user+signing+public+key": "base64+user+signing+master+public+key"
      },
      "signatures": {
        "@alice:example.com": {
          "ed25519:base64+master+public+key": "signature+of+user+signing+key"
        }
      },
      "usage": [
        "user_signing"
      ],
      "user_id": "@alice:example.com"
    }
  }
}
POST /_matrix/client/v3/keys/upload 

Publishes end-to-end encryption keys for the device.

Rate-limited:	No
Requires authentication:	Yes
Request
Request body
Name	Type	Description
device_keys	DeviceKeys	Identity keys for the device. May be absent if no new identity keys are required.
fallback_keys	OneTimeKeys	

The public key which should be used if the device’s one-time keys are exhausted. The fallback key is not deleted once used, but should be replaced when additional one-time keys are being uploaded. The server will notify the client of the fallback key being used through /sync.

There can only be at most one key per algorithm uploaded, and the server will only persist one key per algorithm.

When uploading a signed key, an additional fallback: true key should be included to denote that the key is a fallback key.

May be absent if a new fallback key is not required.

Added in v1.2


one_time_keys	OneTimeKeys	

One-time public keys for “pre-key” messages. The names of the properties should be in the format <algorithm>:<key_id>. The format of the key is determined by the key algorithm.

May be absent if no new one-time keys are required.

DeviceKeys
Name	Type	Description
algorithms	[string]	Required: The encryption algorithms supported by this device.
device_id	string	Required: The ID of the device these keys belong to. Must match the device ID used when logging in.
keys	object	Required: Public identity keys. The names of the properties should be in the format <algorithm>:<device_id>. The keys themselves should be encoded as specified by the key algorithm.
signatures	Signatures	Required:

Signatures for the device key object. A map from user ID, to a map from <algorithm>:<device_id> to the signature.

The signature is calculated using the process described at Signing JSON.


user_id	string	Required: The ID of the user the device belongs to. Must match the user ID used when logging in.
Request body example
{
  "device_keys": {
    "algorithms": [
      "m.olm.v1.curve25519-aes-sha2",
      "m.megolm.v1.aes-sha2"
    ],
    "device_id": "JLAFKJWSCS",
    "keys": {
      "curve25519:JLAFKJWSCS": "3C5BFWi2Y8MaVvjM8M22DBmh24PmgR0nPvJOIArzgyI",
      "ed25519:JLAFKJWSCS": "lEuiRJBit0IG6nUf5pUzWTUEsRVVe/HJkoKuEww9ULI"
    },
    "signatures": {
      "@alice:example.com": {
        "ed25519:JLAFKJWSCS": "dSO80A01XiigH3uBiDVx/EjzaoycHcjq9lfQX0uWsqxl2giMIiSPR8a4d291W1ihKJL/a+myXS367WT6NAIcBA"
      }
    },
    "user_id": "@alice:example.com"
  },
  "fallback_keys": {
    "curve25519:AAAAAG": "/qyvZvwjiTxGdGU0RCguDCLeR+nmsb3FfNG3/Ve4vU8",
    "signed_curve25519:AAAAGj": {
      "fallback": true,
      "key": "zKbLg+NrIjpnagy+pIY6uPL4ZwEG2v+8F9lmgsnlZzs",
      "signatures": {
        "@alice:example.com": {
          "ed25519:JLAFKJWSCS": "FLWxXqGbwrb8SM3Y795eB6OA8bwBcoMZFXBqnTn58AYWZSqiD45tlBVcDa2L7RwdKXebW/VzDlnfVJ+9jok1Bw"
        }
      }
    }
  },
  "one_time_keys": {
    "curve25519:AAAAAQ": "/qyvZvwjiTxGdGU0RCguDCLeR+nmsb3FfNG3/Ve4vU8",
    "signed_curve25519:AAAAHQ": {
      "key": "j3fR3HemM16M7CWhoI4Sk5ZsdmdfQHsKL1xuSft6MSw",
      "signatures": {
        "@alice:example.com": {
          "ed25519:JLAFKJWSCS": "IQeCEPb9HFk217cU9kw9EOiusC6kMIkoIRnbnfOh5Oc63S1ghgyjShBGpu34blQomoalCyXWyhaaT3MrLZYQAA"
        }
      }
    },
    "signed_curve25519:AAAAHg": {
      "key": "zKbLg+NrIjpnagy+pIY6uPL4ZwEG2v+8F9lmgsnlZzs",
      "signatures": {
        "@alice:example.com": {
          "ed25519:JLAFKJWSCS": "FLWxXqGbwrb8SM3Y795eB6OA8bwBcoMZFXBqnTn58AYWZSqiD45tlBVcDa2L7RwdKXebW/VzDlnfVJ+9jok1Bw"
        }
      }
    }
  }
}

Responses
Status	Description
200	The provided keys were successfully uploaded.
200 response
Name	Type	Description
one_time_key_counts	object	Required: For each key algorithm, the number of unclaimed one-time keys of that type currently held on the server for this device. If an algorithm is not listed, the count for that algorithm is to be assumed zero.
{
  "one_time_key_counts": {
    "curve25519": 10,
    "signed_curve25519": 20
  }
}
GET /_matrix/client/v3/pushers 

Gets all currently active pushers for the authenticated user.

Rate-limited:	No
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	The pushers for this user.
200 response
Name	Type	Description
pushers	Pushers	An array containing the current pushers for the user
Pusher
Name	Type	Description
app_display_name	string	Required: A string that will allow the user to identify what application owns this pusher.
app_id	string	Required: This is a reverse-DNS style identifier for the application. Max length, 64 chars.
data	PusherData	Required: A dictionary of information for the pusher implementation itself.
device_display_name	string	Required: A string that will allow the user to identify what device owns this pusher.
kind	string	Required: The kind of pusher. "http" is a pusher that sends HTTP pokes.
lang	string	Required: The preferred language for receiving notifications (e.g. ’en' or ’en-US')
profile_tag	string	This string determines which set of device specific rules this pusher executes.
pushkey	string	Required: This is a unique identifier for this pusher. See /set for more detail. Max length, 512 bytes.
PusherData
Name	Type	Description
format	string	The format to use when sending notifications to the Push Gateway.
url	string	Required if kind is http. The URL to use to send notifications to.
{
  "pushers": [
    {
      "app_display_name": "Appy McAppface",
      "app_id": "face.mcapp.appy.prod",
      "data": {
        "url": "https://example.com/_matrix/push/v1/notify"
      },
      "device_display_name": "Alice's Phone",
      "kind": "http",
      "lang": "en-US",
      "profile_tag": "xyz",
      "pushkey": "Xp/MzCt8/9DcSNE9cuiaoT5Ac55job3TdLSSmtmYl4A="
    }
  ]
}
POST /_matrix/client/v3/pushers/set 

This endpoint allows the creation, modification and deletion of pushers for this user ID. The behaviour of this endpoint varies depending on the values in the JSON body.

If kind is not null, the pusher with this app_id and pushkey for this user is updated, or it is created if it doesn’t exist. If kind is null, the pusher with this app_id and pushkey for this user is deleted.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request body
Name	Type	Description
app_display_name	string	Required if kind is not null. A string that will allow the user to identify what application owns this pusher.
app_id	string	Required:

This is a reverse-DNS style identifier for the application. It is recommended that this end with the platform, such that different platform versions get different app identifiers. Max length, 64 chars.

If the kind is "email", this is "m.email".


append	boolean	If true, the homeserver should add another pusher with the given pushkey and App ID in addition to any others with different user IDs. Otherwise, the homeserver must remove any other pushers with the same App ID and pushkey for different users. The default is false.
data	PusherData	Required if kind is not null. A dictionary of information for the pusher implementation itself. If kind is http, this should contain url which is the URL to use to send notifications to.
device_display_name	string	Required if kind is not null. A string that will allow the user to identify what device owns this pusher.
kind	[string null]	Required: The kind of pusher to configure. "http" makes a pusher that sends HTTP pokes. "email" makes a pusher that emails the user with unread notifications. null deletes the pusher.
lang	string	Required if kind is not null. The preferred language for receiving notifications (e.g. ’en’ or ’en-US’).
profile_tag	string	This string determines which set of device specific rules this pusher executes.
pushkey	string	Required:

This is a unique identifier for this pusher. The value you should use for this is the routing or destination address information for the notification, for example, the APNS token for APNS or the Registration ID for GCM. If your notification client has no such concept, use any unique identifier. Max length, 512 bytes.

If the kind is "email", this is the email address to send notifications to.

PusherData
Name	Type	Description
format	string	The format to send notifications in to Push Gateways if the kind is http. The details about what fields the homeserver should send to the push gateway are defined in the Push Gateway Specification. Currently the only format available is ’event_id_only'.
url	string	Required if kind is http. The URL to use to send notifications to. MUST be an HTTPS URL with a path of /_matrix/push/v1/notify.
Request body example
{
  "app_display_name": "Mat Rix",
  "app_id": "com.example.app.ios",
  "append": false,
  "data": {
    "format": "event_id_only",
    "url": "https://push-gateway.location.here/_matrix/push/v1/notify"
  },
  "device_display_name": "iPhone 9",
  "kind": "http",
  "lang": "en",
  "profile_tag": "xxyyzz",
  "pushkey": "APA91bHPRgkF3JUikC4ENAHEeMrd41Zxv3hVZjC9KtT8OvPVGJ-hQMRKRrZuJAEcl7B338qju59zJMjw2DELjzEvxwYv7hH5Ynpc1ODQ0aT4U4OFEeco8ohsN5PjL1iC2dNtk2BAokeMCg2ZXKqpc8FXKmhX94kIxQ"
}

Responses
Status	Description
200	The pusher was set.
400	One or more of the pusher values were invalid.
429	This request was rate-limited.
200 response
{}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_MISSING_PARAM",
  "error": "Missing parameters: lang, data"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/notifications 

This API is used to paginate through the list of events that the user has been, or would have been notified about.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
from	string	Pagination token to continue from. This should be the next_token returned from an earlier call to this endpoint.
limit	integer	Limit on the number of events to return in this request.
only	string	Allows basic filtering of events returned. Supply highlight to return only events where the notification had the highlight tweak set.
Responses
Status	Description
200	A batch of events is being returned
200 response
Name	Type	Description
next_token	string	The token to supply in the from param of the next /notifications request in order to request more events. If this is absent, there are no more results.
notifications	[Notification]	Required: The list of events that triggered notifications.
Notification
Name	Type	Description
actions	[]	Required: The action(s) to perform when the conditions for this rule are met. See Push Rules: API.
event	Event	Required: The Event object for the event that triggered the notification.
profile_tag	string	The profile tag of the rule that matched this event.
read	boolean	Required: Indicates whether the user has sent a read receipt indicating that they have read this message.
room_id	string	Required: The ID of the room in which the event was posted.
ts	integer	Required: The unix timestamp at which the event notification was sent, in milliseconds.
Event
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEventWithoutRoomID	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "next_token": "abcdef",
  "notifications": [
    {
      "actions": [
        "notify"
      ],
      "event": {
        "content": {
          "body": "This is an example text message",
          "format": "org.matrix.custom.html",
          "formatted_body": "<b>This is an example text message</b>",
          "msgtype": "m.text"
        },
        "event_id": "$143273582443PhrSn:example.org",
        "origin_server_ts": 1432735824653,
        "room_id": "!jEsUZKDJdhlrceRyVU:example.org",
        "sender": "@example:example.org",
        "type": "m.room.message",
        "unsigned": {
          "age": 1234
        }
      },
      "profile_tag": "hcbvkzxhcvb",
      "read": true,
      "room_id": "!abcdefg:example.com",
      "ts": 1475508881945
    }
  ]
}
GET /_matrix/client/v3/pushrules/ 

Retrieve all push rulesets for this user. Clients can “drill-down” on the rulesets by suffixing a scope to this path e.g. /pushrules/global/. This will return a subset of this data under the specified key e.g. the global key.

Rate-limited:	No
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	All the push rulesets for this user.
200 response
Name	Type	Description
global	Ruleset	Required: The global ruleset.
Ruleset
Name	Type	Description
content	[PushRule]	
override	[PushRule]	
room	[PushRule]	
sender	[PushRule]	
underride	[PushRule]	
PushRule
Name	Type	Description
actions	[]	Required: The actions to perform when this rule is matched.
conditions	[PushCondition]	The conditions that must hold true for an event in order for a rule to be applied to an event. A rule with no conditions always matches. Only applicable to underride and override rules.
default	boolean	Required: Whether this is a default rule, or has been set explicitly.
enabled	boolean	Required: Whether the push rule is enabled or not.
pattern	string	The glob-style pattern to match against. Only applicable to content rules.
rule_id	string	Required: The ID of this rule.
PushCondition
Name	Type	Description
is	string	Required for room_member_count conditions. A decimal integer optionally prefixed by one of, ==, <, >, >= or <=. A prefix of < matches rooms where the member count is strictly less than the given number and so forth. If no prefix is present, this parameter defaults to ==.
key	string	

Required for event_match conditions. The dot-separated field of the event to match.

Required for sender_notification_permission conditions. The field in the power level event the user needs a minimum power level for. Fields must be specified under the notifications property in the power level event’s content.


kind	string	Required: The kind of condition to apply. See conditions for more information on the allowed kinds and how they work.
pattern	string	Required for event_match conditions. The glob-style pattern to match against.
{
  "global": {
    "content": [
      {
        "actions": [
          "notify",
          {
            "set_tweak": "sound",
            "value": "default"
          },
          {
            "set_tweak": "highlight"
          }
        ],
        "default": true,
        "enabled": true,
        "pattern": "alice",
        "rule_id": ".m.rule.contains_user_name"
      }
    ],
    "override": [
      {
        "actions": [
          "dont_notify"
        ],
        "conditions": [],
        "default": true,
        "enabled": false,
        "rule_id": ".m.rule.master"
      },
      {
        "actions": [
          "dont_notify"
        ],
        "conditions": [
          {
            "key": "content.msgtype",
            "kind": "event_match",
            "pattern": "m.notice"
          }
        ],
        "default": true,
        "enabled": true,
        "rule_id": ".m.rule.suppress_notices"
      }
    ],
    "room": [],
    "sender": [],
    "underride": [
      {
        "actions": [
          "notify",
          {
            "set_tweak": "sound",
            "value": "ring"
          },
          {
            "set_tweak": "highlight",
            "value": false
          }
        ],
        "conditions": [
          {
            "key": "type",
            "kind": "event_match",
            "pattern": "m.call.invite"
          }
        ],
        "default": true,
        "enabled": true,
        "rule_id": ".m.rule.call"
      },
      {
        "actions": [
          "notify",
          {
            "set_tweak": "sound",
            "value": "default"
          },
          {
            "set_tweak": "highlight"
          }
        ],
        "conditions": [
          {
            "kind": "contains_display_name"
          }
        ],
        "default": true,
        "enabled": true,
        "rule_id": ".m.rule.contains_display_name"
      },
      {
        "actions": [
          "notify",
          {
            "set_tweak": "sound",
            "value": "default"
          },
          {
            "set_tweak": "highlight",
            "value": false
          }
        ],
        "conditions": [
          {
            "is": "2",
            "kind": "room_member_count"
          },
          {
            "key": "type",
            "kind": "event_match",
            "pattern": "m.room.message"
          }
        ],
        "default": true,
        "enabled": true,
        "rule_id": ".m.rule.room_one_to_one"
      },
      {
        "actions": [
          "notify",
          {
            "set_tweak": "sound",
            "value": "default"
          },
          {
            "set_tweak": "highlight",
            "value": false
          }
        ],
        "conditions": [
          {
            "key": "type",
            "kind": "event_match",
            "pattern": "m.room.member"
          },
          {
            "key": "content.membership",
            "kind": "event_match",
            "pattern": "invite"
          },
          {
            "key": "state_key",
            "kind": "event_match",
            "pattern": "@alice:example.com"
          }
        ],
        "default": true,
        "enabled": true,
        "rule_id": ".m.rule.invite_for_me"
      },
      {
        "actions": [
          "notify",
          {
            "set_tweak": "highlight",
            "value": false
          }
        ],
        "conditions": [
          {
            "key": "type",
            "kind": "event_match",
            "pattern": "m.room.member"
          }
        ],
        "default": true,
        "enabled": true,
        "rule_id": ".m.rule.member_event"
      },
      {
        "actions": [
          "notify",
          {
            "set_tweak": "highlight",
            "value": false
          }
        ],
        "conditions": [
          {
            "key": "type",
            "kind": "event_match",
            "pattern": "m.room.message"
          }
        ],
        "default": true,
        "enabled": true,
        "rule_id": ".m.rule.message"
      }
    ]
  }
}
GET /_matrix/client/v3/pushrules/{scope}/{kind}/{ruleId} 

Retrieve a single specified push rule.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
kind	enum	Required: The kind of rule

One of: [override, underride, sender, room, content].


ruleId	string	Required: The identifier for the rule.
scope	string	Required: global to specify global rules.
Responses
Status	Description
200	The specific push rule. This will also include keys specific to the rule itself such as the rule’s actions and conditions if set.
404	The push rule does not exist.
200 response
PushRule
Name	Type	Description
actions	[]	Required: The actions to perform when this rule is matched.
conditions	[PushCondition]	The conditions that must hold true for an event in order for a rule to be applied to an event. A rule with no conditions always matches. Only applicable to underride and override rules.
default	boolean	Required: Whether this is a default rule, or has been set explicitly.
enabled	boolean	Required: Whether the push rule is enabled or not.
pattern	string	The glob-style pattern to match against. Only applicable to content rules.
rule_id	string	Required: The ID of this rule.
PushCondition
Name	Type	Description
is	string	Required for room_member_count conditions. A decimal integer optionally prefixed by one of, ==, <, >, >= or <=. A prefix of < matches rooms where the member count is strictly less than the given number and so forth. If no prefix is present, this parameter defaults to ==.
key	string	

Required for event_match conditions. The dot-separated field of the event to match.

Required for sender_notification_permission conditions. The field in the power level event the user needs a minimum power level for. Fields must be specified under the notifications property in the power level event’s content.


kind	string	Required: The kind of condition to apply. See conditions for more information on the allowed kinds and how they work.
pattern	string	Required for event_match conditions. The glob-style pattern to match against.
{
  "actions": [
    "dont_notify"
  ],
  "default": false,
  "enabled": true,
  "pattern": "cake*lie",
  "rule_id": "nocake"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "The push rule was not found."
}
PUT /_matrix/client/v3/pushrules/{scope}/{kind}/{ruleId} 

This endpoint allows the creation and modification of user defined push rules.

If a rule with the same rule_id already exists among rules of the same kind, it is updated with the new parameters, otherwise a new rule is created.

If both after and before are provided, the new or updated rule must be the next most important rule with respect to the rule identified by before.

If neither after nor before are provided and the rule is created, it should be added as the most important user defined rule among rules of the same kind.

When creating push rules, they MUST be enabled by default.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
kind	enum	Required: The kind of rule

One of: [override, underride, sender, room, content].


ruleId	string	Required: The identifier for the rule. If the string starts with a dot ("."), the request MUST be rejected as this is reserved for server-default rules. Slashes ("/") and backslashes ("\") are also not allowed.
scope	string	Required: global to specify global rules.
query parameters
Name	Type	Description
after	string	This makes the new rule the next-less important rule relative to the given user defined rule. It is not possible to add a rule relative to a predefined server rule.
before	string	Use ‘before’ with a rule_id as its value to make the new rule the next-most important rule with respect to the given user defined rule. It is not possible to add a rule relative to a predefined server rule.
Request body
Name	Type	Description
actions	[]	Required: The action(s) to perform when the conditions for this rule are met.
conditions	[PushCondition]	The conditions that must hold true for an event in order for a rule to be applied to an event. A rule with no conditions always matches. Only applicable to underride and override rules.
pattern	string	Only applicable to content rules. The glob-style pattern to match against.
PushCondition
Name	Type	Description
is	string	Required for room_member_count conditions. A decimal integer optionally prefixed by one of, ==, <, >, >= or <=. A prefix of < matches rooms where the member count is strictly less than the given number and so forth. If no prefix is present, this parameter defaults to ==.
key	string	

Required for event_match conditions. The dot-separated field of the event to match.

Required for sender_notification_permission conditions. The field in the power level event the user needs a minimum power level for. Fields must be specified under the notifications property in the power level event’s content.


kind	string	Required: The kind of condition to apply. See conditions for more information on the allowed kinds and how they work.
pattern	string	Required for event_match conditions. The glob-style pattern to match against.
Request body example
{
  "actions": [
    "notify"
  ],
  "pattern": "cake*lie"
}

Responses
Status	Description
200	The push rule was created/updated.
400	There was a problem configuring this push rule.
404	The push rule does not exist (when updating a push rule).
429	This request was rate-limited.
200 response
{}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNKNOWN",
  "error": "before/after rule not found: someRuleId"
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "The push rule was not found."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
DELETE /_matrix/client/v3/pushrules/{scope}/{kind}/{ruleId} 

This endpoint removes the push rule defined in the path.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
kind	enum	Required: The kind of rule

One of: [override, underride, sender, room, content].


ruleId	string	Required: The identifier for the rule.
scope	string	Required: global to specify global rules.
Responses
Status	Description
200	The push rule was deleted.
404	The push rule does not exist.
200 response
{}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "The push rule was not found."
}
GET /_matrix/client/v3/pushrules/{scope}/{kind}/{ruleId}/actions 

This endpoint get the actions for the specified push rule.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
kind	enum	Required: The kind of rule

One of: [override, underride, sender, room, content].


ruleId	string	Required: The identifier for the rule.
scope	string	Required: Either global or device/<profile_tag> to specify global rules or device rules for the given profile_tag.
Responses
Status	Description
200	The actions for this push rule.
404	The push rule does not exist.
200 response
Name	Type	Description
actions	[]	Required: The action(s) to perform for this rule.
{
  "actions": [
    "notify",
    {
      "set_tweak": "sound",
      "value": "bing"
    }
  ]
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "The push rule was not found."
}
PUT /_matrix/client/v3/pushrules/{scope}/{kind}/{ruleId}/actions 

This endpoint allows clients to change the actions of a push rule. This can be used to change the actions of builtin rules.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
kind	enum	Required: The kind of rule

One of: [override, underride, sender, room, content].


ruleId	string	Required: The identifier for the rule.
scope	string	Required: global to specify global rules.
Request body
Name	Type	Description
actions	[]	Required: The action(s) to perform for this rule.
Request body example
{
  "actions": [
    "notify",
    {
      "set_tweak": "highlight"
    }
  ]
}

Responses
Status	Description
200	The actions for the push rule were set.
404	The push rule does not exist.
200 response
{}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "The push rule was not found."
}
GET /_matrix/client/v3/pushrules/{scope}/{kind}/{ruleId}/enabled 

This endpoint gets whether the specified push rule is enabled.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
kind	enum	Required: The kind of rule

One of: [override, underride, sender, room, content].


ruleId	string	Required: The identifier for the rule.
scope	string	Required: Either global or device/<profile_tag> to specify global rules or device rules for the given profile_tag.
Responses
Status	Description
200	Whether the push rule is enabled.
404	The push rule does not exist.
200 response
Name	Type	Description
enabled	boolean	Required: Whether the push rule is enabled or not.
{
  "enabled": true
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "The push rule was not found."
}
PUT /_matrix/client/v3/pushrules/{scope}/{kind}/{ruleId}/enabled 

This endpoint allows clients to enable or disable the specified push rule.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
kind	enum	Required: The kind of rule

One of: [override, underride, sender, room, content].


ruleId	string	Required: The identifier for the rule.
scope	string	Required: global to specify global rules.
Request body
Name	Type	Description
enabled	boolean	Required: Whether the push rule is enabled or not.
Request body example
{
  "enabled": true
}

Responses
Status	Description
200	The push rule was enabled or disabled.
404	The push rule does not exist.
200 response
{}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "The push rule was not found."
}
POST /_matrix/client/v3/rooms/{roomId}/invite 

Note that there are two forms of this API, which are documented separately. This version of the API does not require that the inviter know the Matrix identifier of the invitee, and instead relies on third party identifiers. The homeserver uses an identity server to perform the mapping from third party identifier to a Matrix identifier. The other is documented in the joining rooms section.

This API invites a user to participate in a particular room. They do not start participating in the room until they actually join the room.

Only users currently in a particular room can invite other users to join that room.

If the identity server did know the Matrix user identifier for the third party identifier, the homeserver will append a m.room.member event to the room.

If the identity server does not know a Matrix user identifier for the passed third party identifier, the homeserver will issue an invitation which can be accepted upon providing proof of ownership of the third party identifier. This is achieved by the identity server generating a token, which it gives to the inviting homeserver. The homeserver will add an m.room.third_party_invite event into the graph for the room, containing that token.

When the invitee binds the invited third party identifier to a Matrix user ID, the identity server will give the user a list of pending invitations, each containing:

The room ID to which they were invited

The token given to the homeserver

A signature of the token, signed with the identity server’s private key

The matrix user ID who invited them to the room

If a token is requested from the identity server, the homeserver will append a m.room.third_party_invite event to the room.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room identifier (not alias) to which to invite the user.
Request body
Name	Type	Description
address	string	Required: The invitee’s third party identifier.
id_access_token	string	Required: An access token previously registered with the identity server. Servers can treat this as optional to distinguish between r0.5-compatible clients and this specification version.
id_server	string	Required: The hostname+port of the identity server which should be used for third party identifier lookups.
medium	string	Required: The kind of address being passed in the address field, for example email (see the list of recognised values).
Request body example
{
  "address": "cheeky@monkey.com",
  "id_access_token": "abc123_OpaqueString",
  "id_server": "matrix.org",
  "medium": "email"
}

Responses
Status	Description
200	The user has been invited to join the room.
403	

You do not have permission to invite the user to the room. A meaningful errcode and description error text will be returned. Example reasons for rejections are:

The invitee has been banned from the room.
The invitee is already a member of the room.
The inviter is not currently in the room.
The inviter’s power level is insufficient to invite users to the room.

429	This request was rate-limited.
200 response
{}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "@cheeky_monkey:matrix.org is banned from the room"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/search 

Performs a full text search across different categories.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
next_batch	string	The point to return events from. If given, this should be a next_batch result from a previous call to this endpoint.
Request body
Name	Type	Description
search_categories	Categories	Required: Describes which categories to search in and their criteria.
Categories
Name	Type	Description
room_events	Room Events Criteria	Mapping of category name to search criteria.
Room Events Criteria
Name	Type	Description
event_context	Include Event Context	Configures whether any context for the events returned are included in the response.
filter	Filter	This takes a filter.
groupings	Groupings	Requests that the server partitions the result set based on the provided list of keys.
include_state	Include current state	Requests the server return the current state for each room returned.
keys	[string]	The keys to search. Defaults to all.
order_by	Ordering	The order in which to search for results. By default, this is "rank".
search_term	string	Required: The string to search events for
Include Event Context
Name	Type	Description
after_limit	After limit	How many events after the result are returned. By default, this is 5.
before_limit	Before limit	How many events before the result are returned. By default, this is 5.
include_profile	Return profile information	Requests that the server returns the historic profile information for the users that sent the events that were returned. By default, this is false.
Filter
Name	Type	Description
contains_url	boolean	If true, includes only events with a url key in their content. If false, excludes those events. If omitted, url key is not considered for filtering.
include_redundant_members	boolean	If true, sends all membership events for all events, even if they have already been sent to the client. Does not apply unless lazy_load_members is true. See Lazy-loading room members for more information. Defaults to false.
lazy_load_members	boolean	If true, enables lazy-loading of membership events. See Lazy-loading room members for more information. Defaults to false.
limit	integer	The maximum number of events to return.
not_rooms	[string]	A list of room IDs to exclude. If this list is absent then no rooms are excluded. A matching room will be excluded even if it is listed in the 'rooms' filter.
not_senders	[string]	A list of sender IDs to exclude. If this list is absent then no senders are excluded. A matching sender will be excluded even if it is listed in the 'senders' filter.
not_types	[string]	A list of event types to exclude. If this list is absent then no event types are excluded. A matching type will be excluded even if it is listed in the 'types' filter. A ‘*’ can be used as a wildcard to match any sequence of characters.
rooms	[string]	A list of room IDs to include. If this list is absent then all rooms are included.
senders	[string]	A list of senders IDs to include. If this list is absent then all senders are included.
types	[string]	A list of event types to include. If this list is absent then all event types are included. A '*' can be used as a wildcard to match any sequence of characters.
unread_thread_notifications	boolean	If true, enables per-thread notification counts. Only applies to the /sync endpoint. Defaults to false.

Added in v1.4

Groupings
Name	Type	Description
group_by	Groups	List of groups to request.
Group
Name	Type	Description
key	Group Key	Key that defines the group.
Request body example
{
  "search_categories": {
    "room_events": {
      "groupings": {
        "group_by": [
          {
            "key": "room_id"
          }
        ]
      },
      "keys": [
        "content.body"
      ],
      "order_by": "recent",
      "search_term": "martians and men"
    }
  }
}

Responses
Status	Description
200	Results of the search.
400	Part of the request was invalid.
429	This request was rate-limited.
200 response
Results
Name	Type	Description
search_categories	Result Categories	Required: Describes which categories to search in and their criteria.
Result Categories
Name	Type	Description
room_events	Result Room Events	Mapping of category name to search criteria.
Result Room Events
Name	Type	Description
count	integer	An approximate count of the total number of results found.
groups	{string: Group Key}	

Any groups that were requested.

The outer string key is the group key requested (eg: room_id or sender). The inner string key is the grouped value (eg: a room’s ID or a user’s ID).


highlights	Highlights	List of words which should be highlighted, useful for stemming which may change the query terms.
next_batch	Next Batch	Token that can be used to get the next batch of results, by passing as the next_batch parameter to the next call. If this field is absent, there are no more results.
results	Results	List of results in the requested order.
state	{string: Room State}	

The current state for every room in the results. This is included if the request had the include_state key set with a value of true.

The string key is the room ID for which the State Event array belongs to.

Result
Name	Type	Description
context	Event Context	Context for result, if requested.
rank	number	A number that describes how closely this result matches the search. Higher is closer.
result	Event	The event that matched.
Event Context
Name	Type	Description
end	End Token	Pagination token for the end of the chunk
events_after	Events After	Events just after the result.
events_before	Events Before	Events just before the result.
profile_info	{string: User Profile}	

The historic profile information of the users that sent the events returned.

The string key is the user ID for which the profile belongs to.


start	Start Token	Pagination token for the start of the chunk
Event
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
User Profile
Name	Type	Description
avatar_url	Avatar Url	
displayname	Display name	
{
  "search_categories": {
    "room_events": {
      "count": 1224,
      "groups": {
        "room_id": {
          "!qPewotXpIctQySfjSy:localhost": {
            "next_batch": "BdgFsdfHSf-dsFD",
            "order": 1,
            "results": [
              "$144429830826TWwbB:localhost"
            ]
          }
        }
      },
      "highlights": [
        "martians",
        "men"
      ],
      "next_batch": "5FdgFsd234dfgsdfFD",
      "results": [
        {
          "rank": 0.00424866,
          "result": {
            "content": {
              "body": "This is an example text message",
              "format": "org.matrix.custom.html",
              "formatted_body": "<b>This is an example text message</b>",
              "msgtype": "m.text"
            },
            "event_id": "$144429830826TWwbB:localhost",
            "origin_server_ts": 1432735824653,
            "room_id": "!qPewotXpIctQySfjSy:localhost",
            "sender": "@example:example.org",
            "type": "m.room.message",
            "unsigned": {
              "age": 1234
            }
          }
        }
      ]
    }
  }
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v3/events 

This will listen for new events related to a particular room and return them to the caller. This will block until an event is received, or until the timeout is reached.

This API is the same as the normal /events endpoint, but can be called by users who have not joined the room.

Note that the normal /events endpoint has been deprecated. This API will also be deprecated at some point, but its replacement is not yet known.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
from	string	The token to stream from. This token is either from a previous request to this API or from the initial sync API.
room_id	string	The room ID for which events should be returned.
timeout	integer	The maximum time in milliseconds to wait for an event.
Responses
Status	Description
200	The events received, which may be none.
400	Bad pagination from parameter.
200 response
Name	Type	Description
chunk	[Event]	An array of events.
end	string	A token which correlates to the last value in chunk. This token should be used in the next request to /events.
start	string	A token which correlates to the first value in chunk. This is usually the same token supplied to from=.
Event
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "chunk": [
    {
      "content": {
        "body": "This is an example text message",
        "format": "org.matrix.custom.html",
        "formatted_body": "<b>This is an example text message</b>",
        "msgtype": "m.text"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!somewhere:over.the.rainbow",
      "sender": "@example:example.org",
      "type": "m.room.message",
      "unsigned": {
        "age": 1234
      }
    }
  ],
  "end": "s3457_9_0",
  "start": "s3456_9_0"
}
GET /_matrix/client/v3/user/{userId}/rooms/{roomId}/tags 

List the tags set by a user on a room.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room to get tags for.
userId	string	Required: The id of the user to get tags for. The access token must be authorized to make requests for this user ID.
Responses
Status	Description
200	The list of tags for the user for the room.
200 response
Name	Type	Description
tags	{string: Tag}	
Tag
Name	Type	Description
order	number	A number in a range [0,1] describing a relative position of the room under the given tag.
{
  "tags": {
    "m.favourite": {
      "order": 0.1
    },
    "u.Customers": {},
    "u.Work": {
      "order": 0.7
    }
  }
}
PUT /_matrix/client/v3/user/{userId}/rooms/{roomId}/tags/{tag} 

Add a tag to the room.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room to add a tag to.
tag	string	Required: The tag to add.
userId	string	Required: The id of the user to add a tag for. The access token must be authorized to make requests for this user ID.
Request body
Name	Type	Description
order	number	A number in a range [0,1] describing a relative position of the room under the given tag.
Request body example
{
  "order": 0.25
}

Responses
Status	Description
200	The tag was successfully added.
200 response
{}
DELETE /_matrix/client/v3/user/{userId}/rooms/{roomId}/tags/{tag} 

Remove a tag from the room.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room to remove a tag from.
tag	string	Required: The tag to remove.
userId	string	Required: The id of the user to remove a tag for. The access token must be authorized to make requests for this user ID.
Responses
Status	Description
200	The tag was successfully removed.
200 response
{}
GET /_matrix/client/v3/user/{userId}/account_data/{type} 

Get some account data for the client. This config is only visible to the user that set the account data.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
type	string	Required: The event type of the account data to get. Custom types should be namespaced to avoid clashes.
userId	string	Required: The ID of the user to get account data for. The access token must be authorized to make requests for this user ID.
Responses
Status	Description
200	The account data content for the given type.
403	The access token provided is not authorized to retrieve this user’s account data. Errcode: M_FORBIDDEN.
404	No account data has been provided for this user with the given type. Errcode: M_NOT_FOUND.
200 response
{
  "custom_account_data_key": "custom_config_value"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "Cannot add account data for other users."
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Account data not found."
}
PUT /_matrix/client/v3/user/{userId}/account_data/{type} 

Set some account data for the client. This config is only visible to the user that set the account data. The config will be available to clients through the top-level account_data field in the homeserver response to /sync.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
type	string	Required: The event type of the account data to set. Custom types should be namespaced to avoid clashes.
userId	string	Required: The ID of the user to set account data for. The access token must be authorized to make requests for this user ID.
Request body
Request body example
{
  "custom_account_data_key": "custom_config_value"
}

Responses
Status	Description
200	The account data was successfully added.
400	The request body is not a JSON object. Errcode: M_BAD_JSON or M_NOT_JSON.
403	The access token provided is not authorized to modify this user’s account data. Errcode: M_FORBIDDEN.
405	This type of account data is controlled by the server; it cannot be modified by clients. Errcode: M_BAD_JSON.
200 response
{}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_JSON",
  "error": "Content must be a JSON object."
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "Cannot add account data for other users."
}

405 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_BAD_JSON",
  "error": "Cannot set m.fully_read through this API."
}
GET /_matrix/client/v3/user/{userId}/rooms/{roomId}/account_data/{type} 

Get some account data for the client on a given room. This config is only visible to the user that set the account data.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room to get account data for.
type	string	Required: The event type of the account data to get. Custom types should be namespaced to avoid clashes.
userId	string	Required: The ID of the user to get account data for. The access token must be authorized to make requests for this user ID.
Responses
Status	Description
200	The account data content for the given type.
400	The given roomID is not a valid room ID. Errcode: M_INVALID_PARAM.
403	The access token provided is not authorized to retrieve this user’s account data. Errcode: M_FORBIDDEN.
404	No account data has been provided for this user and this room with the given type. Errcode: M_NOT_FOUND.
200 response
{
  "custom_account_data_key": "custom_config_value"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "Cannot add account data for other users."
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND",
  "error": "Room account data not found."
}
PUT /_matrix/client/v3/user/{userId}/rooms/{roomId}/account_data/{type} 

Set some account data for the client on a given room. This config is only visible to the user that set the account data. The config will be delivered to clients in the per-room entries via /sync.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room to set account data on.
type	string	Required: The event type of the account data to set. Custom types should be namespaced to avoid clashes.
userId	string	Required: The ID of the user to set account data for. The access token must be authorized to make requests for this user ID.
Request body
Request body example
{
  "custom_account_data_key": "custom_account_data_value"
}

Responses
Status	Description
200	The account data was successfully added.
400	The request body is not a JSON object (errcode M_BAD_JSON or M_NOT_JSON), or the given roomID is not a valid room ID (errcode M_INVALID_PARAM).
403	The access token provided is not authorized to modify this user’s account data. Errcode: M_FORBIDDEN.
405	This type of account data is controlled by the server; it cannot be modified by clients. Errcode: M_BAD_JSON.
200 response
{}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_JSON",
  "error": "Content must be a JSON object."
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "Cannot add account data for other users."
}

405 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_BAD_JSON",
  "error": "Cannot set m.fully_read through this API."
}
GET /_matrix/client/v3/admin/whois/{userId} 

Gets information about a particular user.

This API may be restricted to only be called by the user being looked up, or by a server admin. Server-local administrator privileges are not specified in this document.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
userId	string	Required: The user to look up.
Responses
Status	Description
200	The lookup was successful.
200 response
Name	Type	Description
devices	{string: DeviceInfo}	Each key is an identifier for one of the user’s devices.
user_id	string	The Matrix user ID of the user.
DeviceInfo
Name	Type	Description
sessions	[SessionInfo]	A user’s sessions (i.e. what they did with an access token from one login).
SessionInfo
Name	Type	Description
connections	[ConnectionInfo]	Information particular connections in the session.
ConnectionInfo
Name	Type	Description
ip	string	Most recently seen IP address of the session.
last_seen	integer	Unix timestamp that the session was last active.
user_agent	string	User agent string last seen in the session.
{
  "devices": {
    "teapot": {
      "sessions": [
        {
          "connections": [
            {
              "ip": "127.0.0.1",
              "last_seen": 1411996332123,
              "user_agent": "curl/7.31.0-DEV"
            },
            {
              "ip": "10.0.0.2",
              "last_seen": 1411996332123,
              "user_agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36"
            }
          ]
        }
      ]
    }
  },
  "user_id": "@peter:rabbit.rocks"
}
GET /_matrix/client/v3/rooms/{roomId}/context/{eventId} 

This API returns a number of events that happened just before and after the specified event. This allows clients to get the context surrounding an event.

Note: This endpoint supports lazy-loading of room member events. See Lazy-loading room members for more information.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventId	string	Required: The event to get context around.
roomId	string	Required: The room to get events from.
query parameters
Name	Type	Description
filter	string	

A JSON RoomEventFilter to filter the returned events with. The filter is only applied to events_before, events_after, and state. It is not applied to the event itself. The filter may be applied before or/and after the limit parameter - whichever the homeserver prefers.

See Filtering for more information.


limit	integer	The maximum number of context events to return. The limit applies to the sum of the events_before and events_after arrays. The requested event ID is always returned in event even if limit is 0. Defaults to 10.
Responses
Status	Description
200	The events and state surrounding the requested event.
200 response
Name	Type	Description
end	string	A token that can be used to paginate forwards with.
event	ClientEvent	Details of the requested event.
events_after	[ClientEvent]	A list of room events that happened just after the requested event, in chronological order.
events_before	[ClientEvent]	A list of room events that happened just before the requested event, in reverse-chronological order.
start	string	A token that can be used to paginate backwards with.
state	[ClientEvent]	The state of the room at the last event returned.
ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "end": "t29-57_2_0_2",
  "event": {
    "content": {
      "body": "filename.jpg",
      "info": {
        "h": 398,
        "mimetype": "image/jpeg",
        "size": 31037,
        "w": 394
      },
      "msgtype": "m.image",
      "url": "mxc://example.org/JWEIFJgwEIhweiWJE"
    },
    "event_id": "$f3h4d129462ha:example.com",
    "origin_server_ts": 1432735824653,
    "room_id": "!636q39766251:example.com",
    "sender": "@example:example.org",
    "type": "m.room.message",
    "unsigned": {
      "age": 1234
    }
  },
  "events_after": [
    {
      "content": {
        "body": "This is an example text message",
        "format": "org.matrix.custom.html",
        "formatted_body": "<b>This is an example text message</b>",
        "msgtype": "m.text"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "type": "m.room.message",
      "unsigned": {
        "age": 1234
      }
    }
  ],
  "events_before": [
    {
      "content": {
        "body": "something-important.doc",
        "filename": "something-important.doc",
        "info": {
          "mimetype": "application/msword",
          "size": 46144
        },
        "msgtype": "m.file",
        "url": "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "type": "m.room.message",
      "unsigned": {
        "age": 1234
      }
    }
  ],
  "start": "t27-54_2_0_2",
  "state": [
    {
      "content": {
        "creator": "@example:example.org",
        "m.federate": true,
        "predecessor": {
          "event_id": "$something:example.org",
          "room_id": "!oldroom:example.org"
        },
        "room_version": "1"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "state_key": "",
      "type": "m.room.create",
      "unsigned": {
        "age": 1234
      }
    },
    {
      "content": {
        "avatar_url": "mxc://example.org/SEsfnsuifSDFSSEF",
        "displayname": "Alice Margatroid",
        "membership": "join",
        "reason": "Looking for support"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!636q39766251:example.com",
      "sender": "@example:example.org",
      "state_key": "@alice:example.org",
      "type": "m.room.member",
      "unsigned": {
        "age": 1234
      }
    }
  ]
}
GET /_matrix/client/v3/login/sso/redirect 

Added in v1.1

A web-based Matrix client should instruct the user’s browser to navigate to this endpoint in order to log in via SSO.

The server MUST respond with an HTTP redirect to the SSO interface, or present a page which lets the user select an IdP to continue with in the event multiple are supported by the server.

Rate-limited:	No
Requires authentication:	No
Request
Request parameters
query parameters
Name	Type	Description
redirectUrl	string	Required: URI to which the user will be redirected after the homeserver has authenticated the user with SSO.
Responses
Status	Description
302	A redirect to the SSO interface.GET /_matrix/client/v3/login/sso/redirect/{idpId} 

Added in v1.1

This endpoint is the same as /login/sso/redirect, though with an IdP ID from the original identity_providers array to inform the server of which IdP the client/user would like to continue with.

The server MUST respond with an HTTP redirect to the SSO interface for that IdP.

Rate-limited:	No
Requires authentication:	No
Request
Request parameters
path parameters
Name	Type	Description
idpId	string	Required: The id of the IdP from the m.login.sso identity_providers array denoting the user’s selection.
query parameters
Name	Type	Description
redirectUrl	string	Required: URI to which the user will be redirected after the homeserver has authenticated the user with SSO.
Responses
Status	Description
302	A redirect to the SSO interface.
404	The IdP ID was not recognized by the server. The server is encouraged to provide a user-friendly page explaining the error given the user will be navigated to it.POST /_matrix/client/v3/rooms/{roomId}/report/{eventId} 

Reports an event as inappropriate to the server, which may then notify the appropriate people.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
eventId	string	Required: The event to report.
roomId	string	Required: The room in which the event being reported is located.
Request body
Name	Type	Description
reason	string	The reason the content is being reported. May be blank.
score	integer	The score to rate this content as where -100 is most offensive and 0 is inoffensive.
Request body example
{
  "reason": "this makes me sad",
  "score": -100
}

Responses
Status	Description
200	The event has been reported successfully.
200 response
{}
GET /_matrix/client/v3/thirdparty/location 

Retrieve an array of third party network locations from a Matrix room alias.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
alias	string	Required: The Matrix room alias to look up.
Responses
Status	Description
200	All found third party locations.
404	The Matrix room alias was not found
200 response

Array of Location.

Location
Name	Type	Description
alias	string	Required: An alias for a matrix room.
fields	object	Required: Information used to identify this third party location.
protocol	string	Required: The protocol ID that the third party location is a part of.
[
  {
    "alias": "#freenode_#matrix:matrix.org",
    "fields": {
      "channel": "#matrix",
      "network": "freenode"
    },
    "protocol": "irc"
  }
]

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND"
}
GET /_matrix/client/v3/thirdparty/location/{protocol} 

Requesting this endpoint with a valid protocol name results in a list of successful mapping results in a JSON array. Each result contains objects to represent the Matrix room or rooms that represent a portal to this third party network. Each has the Matrix room alias string, an identifier for the particular third party network protocol, and an object containing the network-specific fields that comprise this identifier. It should attempt to canonicalise the identifier as much as reasonably possible given the network type.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
protocol	string	Required: The protocol used to communicate to the third party network.
query parameters
Name	Type	Description
searchFields	string	One or more custom fields to help identify the third party location.
Responses
Status	Description
200	At least one portal room was found.
404	No portal rooms were found.
200 response

Array of Location.

Location
Name	Type	Description
alias	string	Required: An alias for a matrix room.
fields	object	Required: Information used to identify this third party location.
protocol	string	Required: The protocol ID that the third party location is a part of.
[
  {
    "alias": "#freenode_#matrix:matrix.org",
    "fields": {
      "channel": "#matrix",
      "network": "freenode"
    },
    "protocol": "irc"
  }
]

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND"
}
GET /_matrix/client/v3/thirdparty/protocol/{protocol} 

Fetches the metadata from the homeserver about a particular third party protocol.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
protocol	string	Required: The name of the protocol.
Responses
Status	Description
200	The protocol was found and metadata returned.
404	The protocol is unknown.
200 response
Protocol
Name	Type	Description
field_types	{string: Field Type}	Required:

The type definitions for the fields defined in the user_fields and location_fields. Each entry in those arrays MUST have an entry here. The string key for this object is field name itself.

May be an empty object if no fields are defined.


icon	string	Required: A content URI representing an icon for the third party protocol.
instances	[Protocol Instance]	Required: A list of objects representing independent instances of configuration. For example, multiple networks on IRC if multiple are provided by the same application service.
location_fields	[string]	Required: Fields which may be used to identify a third party location. These should be ordered to suggest the way that entities may be grouped, where higher groupings are ordered first. For example, the name of a network should be searched before the name of a channel.
user_fields	[string]	Required: Fields which may be used to identify a third party user. These should be ordered to suggest the way that entities may be grouped, where higher groupings are ordered first. For example, the name of a network should be searched before the nickname of a user.
Field Type
Name	Type	Description
placeholder	string	Required: An placeholder serving as a valid example of the field value.
regexp	string	Required: A regular expression for validation of a field’s value. This may be relatively coarse to verify the value as the application service providing this protocol may apply additional validation or filtering.
Protocol Instance
Name	Type	Description
desc	string	Required: A human-readable description for the protocol, such as the name.
fields	object	Required: Preset values for fields the client may use to search by.
icon	string	An optional content URI representing the protocol. Overrides the one provided at the higher level Protocol object.
network_id	string	Required: A unique identifier across all instances.
{
  "field_types": {
    "channel": {
      "placeholder": "#foobar",
      "regexp": "#[^\\s]+"
    },
    "network": {
      "placeholder": "irc.example.org",
      "regexp": "([a-z0-9]+\\.)*[a-z0-9]+"
    },
    "nickname": {
      "placeholder": "username",
      "regexp": "[^\\s#]+"
    }
  },
  "icon": "mxc://example.org/aBcDeFgH",
  "instances": [
    {
      "desc": "Freenode",
      "fields": {
        "network": "freenode"
      },
      "icon": "mxc://example.org/JkLmNoPq",
      "network_id": "freenode"
    }
  ],
  "location_fields": [
    "network",
    "channel"
  ],
  "user_fields": [
    "network",
    "nickname"
  ]
}

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND"
}
GET /_matrix/client/v3/thirdparty/protocols 

Fetches the overall metadata about protocols supported by the homeserver. Includes both the available protocols and all fields required for queries against each protocol.

Rate-limited:	No
Requires authentication:	Yes
Request

No request parameters or request body.

Responses
Status	Description
200	The protocols supported by the homeserver.
200 response
Protocol
Name	Type	Description
field_types	{string: Field Type}	Required:

The type definitions for the fields defined in the user_fields and location_fields. Each entry in those arrays MUST have an entry here. The string key for this object is field name itself.

May be an empty object if no fields are defined.


icon	string	Required: A content URI representing an icon for the third party protocol.
instances	[Protocol Instance]	Required: A list of objects representing independent instances of configuration. For example, multiple networks on IRC if multiple are provided by the same application service.
location_fields	[string]	Required: Fields which may be used to identify a third party location. These should be ordered to suggest the way that entities may be grouped, where higher groupings are ordered first. For example, the name of a network should be searched before the name of a channel.
user_fields	[string]	Required: Fields which may be used to identify a third party user. These should be ordered to suggest the way that entities may be grouped, where higher groupings are ordered first. For example, the name of a network should be searched before the nickname of a user.
Field Type
Name	Type	Description
placeholder	string	Required: An placeholder serving as a valid example of the field value.
regexp	string	Required: A regular expression for validation of a field’s value. This may be relatively coarse to verify the value as the application service providing this protocol may apply additional validation or filtering.
Protocol Instance
Name	Type	Description
desc	string	Required: A human-readable description for the protocol, such as the name.
fields	object	Required: Preset values for fields the client may use to search by.
icon	string	An optional content URI representing the protocol. Overrides the one provided at the higher level Protocol object.
network_id	string	Required: A unique identifier across all instances.
{
  "gitter": {
    "field_types": {
      "room": {
        "placeholder": "matrix-org/matrix-doc",
        "regexp": "[^\\s]+\\/[^\\s]+"
      },
      "username": {
        "placeholder": "@username",
        "regexp": "@[^\\s]+"
      }
    },
    "instances": [
      {
        "desc": "Gitter",
        "fields": {},
        "icon": "mxc://example.org/zXyWvUt",
        "network_id": "gitter"
      }
    ],
    "location_fields": [
      "room"
    ],
    "user_fields": [
      "username"
    ]
  },
  "irc": {
    "field_types": {
      "channel": {
        "placeholder": "#foobar",
        "regexp": "#[^\\s]+"
      },
      "network": {
        "placeholder": "irc.example.org",
        "regexp": "([a-z0-9]+\\.)*[a-z0-9]+"
      },
      "nickname": {
        "placeholder": "username",
        "regexp": "[^\\s]+"
      }
    },
    "icon": "mxc://example.org/aBcDeFgH",
    "instances": [
      {
        "desc": "Freenode",
        "fields": {
          "network": "freenode.net"
        },
        "icon": "mxc://example.org/JkLmNoPq",
        "network_id": "freenode"
      }
    ],
    "location_fields": [
      "network",
      "channel"
    ],
    "user_fields": [
      "network",
      "nickname"
    ]
  }
}
GET /_matrix/client/v3/thirdparty/user 

Retrieve an array of third party users from a Matrix User ID.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
query parameters
Name	Type	Description
userid	string	Required: The Matrix User ID to look up.
Responses
Status	Description
200	An array of third party users.
404	The Matrix User ID was not found
200 response

Array of User.

User
Name	Type	Description
fields	object	Required: Information used to identify this third party location.
protocol	string	Required: The protocol ID that the third party location is a part of.
userid	string	Required: A Matrix User ID represting a third party user.
[
  {
    "fields": {
      "user": "jim"
    },
    "protocol": "gitter",
    "userid": "@_gitter_jim:matrix.org"
  }
]

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND"
}
GET /_matrix/client/v3/thirdparty/user/{protocol} 

Retrieve a Matrix User ID linked to a user on the third party service, given a set of user parameters.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
protocol	string	Required: The name of the protocol.
query parameters
Name	Type	Description
fields...	string	One or more custom fields that are passed to the AS to help identify the user.
Responses
Status	Description
200	The Matrix User IDs found with the given parameters.
404	The Matrix User ID was not found
200 response

Array of User.

User
Name	Type	Description
fields	object	Required: Information used to identify this third party location.
protocol	string	Required: The protocol ID that the third party location is a part of.
userid	string	Required: A Matrix User ID represting a third party user.
[
  {
    "fields": {
      "user": "jim"
    },
    "protocol": "gitter",
    "userid": "@_gitter_jim:matrix.org"
  }
]

404 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_NOT_FOUND"
}
POST /_matrix/client/v3/user/{userId}/openid/request_token 

Gets an OpenID token object that the requester may supply to another service to verify their identity in Matrix. The generated token is only valid for exchanging for user information from the federation API for OpenID.

The access token generated is only valid for the OpenID API. It cannot be used to request another OpenID access token or call /sync, for example.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
userId	string	Required: The user to request an OpenID token for. Should be the user who is authenticated for the request.
Request body
Request body example
{}

Responses
Status	Description
200	OpenID token information. This response is nearly compatible with the response documented in the OpenID Connect 1.0 Specification with the only difference being the lack of an id_token. Instead, the Matrix homeserver’s name is provided.
429	This request was rate-limited.
200 response
OpenIdCredentials
Name	Type	Description
access_token	string	Required: An access token the consumer may use to verify the identity of the person who generated the token. This is given to the federation API GET /openid/userinfo to verify the user’s identity.
expires_in	integer	Required: The number of seconds before this token expires and a new one must be generated.
matrix_server_name	string	Required: The homeserver domain the consumer should use when attempting to verify the user’s identity.
token_type	string	Required: The string Bearer.
{
  "access_token": "SomeT0kenHere",
  "expires_in": 3600,
  "matrix_server_name": "example.com",
  "token_type": "Bearer"
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
POST /_matrix/client/v3/rooms/{roomId}/upgrade 

Upgrades the given room to a particular room version.

Rate-limited:	No
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The ID of the room to upgrade.
Request body
Name	Type	Description
new_version	string	Required: The new version for the room.
Request body example
{
  "new_version": "2"
}

Responses
Status	Description
200	The room was successfully upgraded.
400	The request was invalid. One way this can happen is if the room version requested is not supported by the homeserver.
403	The user is not permitted to upgrade the room.
200 response
Name	Type	Description
replacement_room	string	Required: The ID of the new room.
{
  "replacement_room": "!newroom:example.org"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_UNSUPPORTED_ROOM_VERSION",
  "error": "This server does not support that room version"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You cannot upgrade this room"
}
GET /_matrix/client/v1/rooms/{roomId}/hierarchy 

Added in v1.2

Paginates over the space tree in a depth-first manner to locate child rooms of a given space.

Where a child room is unknown to the local server, federation is used to fill in the details. The servers listed in the via array should be contacted to attempt to fill in missing rooms.

Only m.space.child state events of the room are considered. Invalid child rooms and parent events are not covered by this endpoint.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room ID of the space to get a hierarchy for.
query parameters
Name	Type	Description
from	string	A pagination token from a previous result. If specified, max_depth and suggested_only cannot be changed from the first request.
limit	integer	

Optional limit for the maximum number of rooms to include per response. Must be an integer greater than zero.

Servers should apply a default value, and impose a maximum value to avoid resource exhaustion.


max_depth	integer	

Optional limit for how far to go into the space. Must be a non-negative integer.

When reached, no further child rooms will be returned.

Servers should apply a default value, and impose a maximum value to avoid resource exhaustion.


suggested_only	boolean	Optional (default false) flag to indicate whether or not the server should only consider suggested rooms. Suggested rooms are annotated in their m.space.child event contents.
Responses
Status	Description
200	A portion of the space tree, starting at the provided room ID.
400	

The request was invalid in some way. A meaningful errcode and description error text will be returned. Example reasons for rejection are:

The from token is unknown to the server.
suggested_only or max_depth changed during pagination.

403	

The user cannot view or peek on the room. A meaningful errcode and description error text will be returned. Example reasons for rejection are:

The room is not set up for peeking.
The user has been banned from the room.
The room does not exist.

429	This request was rate-limited.
200 response
Name	Type	Description
next_batch	string	A token to supply to from to keep paginating the responses. Not present when there are no further results.
rooms	[ChildRoomsChunk]	Required: The rooms for the current page, with the current filters.
ChildRoomsChunk
Name	Type	Description
avatar_url	string	The URL for the room’s avatar, if one is set.
canonical_alias	string	The canonical alias of the room, if any.
children_state	[StrippedChildStateEvent]	Required:

The m.space.child events of the space-room, represented as Stripped State Events with an added origin_server_ts key.

If the room is not a space-room, this should be empty.


guest_can_join	boolean	Required: Whether guest users may join the room and participate in it. If they can, they will be subject to ordinary power level rules like any other user.
join_rule	string	The room’s join rule. When not present, the room is assumed to be public.
name	string	The name of the room, if any.
num_joined_members	integer	Required: The number of members joined to the room.
room_id	string	Required: The ID of the room.
room_type	string	The type of room (from m.room.create), if any.

Added in v1.4


topic	string	The topic of the room, if any.
world_readable	boolean	Required: Whether the room may be viewed by guest users without joining.
StrippedChildStateEvent
Name	Type	Description
content	EventContent	Required: The content for the event.
origin_server_ts	integer	Required: The origin_server_ts for the event.
sender	string	Required: The sender for the event.
state_key	string	Required: The state_key for the event.
type	string	Required: The type for the event.
{
  "next_batch": "next_batch_token",
  "rooms": [
    {
      "avatar_url": "mxc://example.org/abcdef",
      "canonical_alias": "#general:example.org",
      "children_state": [
        {
          "content": {
            "via": [
              "example.org"
            ]
          },
          "origin_server_ts": 1629413349153,
          "sender": "@alice:example.org",
          "state_key": "!a:example.org",
          "type": "m.space.child"
        }
      ],
      "guest_can_join": false,
      "join_rule": "public",
      "name": "The First Space",
      "num_joined_members": 42,
      "room_id": "!space:example.org",
      "room_type": "m.space",
      "topic": "No other spaces were created first, ever",
      "world_readable": true
    }
  ]
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_INVALID_PARAM",
  "error": "suggested_only and max_depth cannot change on paginated requests"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You are not allowed to view this room."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
GET /_matrix/client/v1/rooms/{roomId}/threads 

Added in v1.4

Paginates over the thread roots in a room, ordered by the latest_event of each thread root in its bundle.

Rate-limited:	Yes
Requires authentication:	Yes
Request
Request parameters
path parameters
Name	Type	Description
roomId	string	Required: The room ID where the thread roots are located.
query parameters
Name	Type	Description
from	string	A pagination token from a previous result. When not provided, the server starts paginating from the most recent event visible to the user (as per history visibility rules; topologically).
include	enum	Optional (default all) flag to denote which thread roots are of interest to the caller. When all, all thread roots found in the room are returned. When participated, only thread roots for threads the user has participated in will be returned.

One of: [all, participated].


limit	integer	

Optional limit for the maximum number of thread roots to include per response. Must be an integer greater than zero.

Servers should apply a default value, and impose a maximum value to avoid resource exhaustion.

Responses
Status	Description
200	A portion of the available thread roots in the room, based on the filter criteria.
400	

The request was invalid in some way. A meaningful errcode and description error text will be returned. Example reasons for rejection are:

The from token is unknown to the server.

403	

The user cannot view or peek on the room. A meaningful errcode and description error text will be returned. Example reasons for rejection are:

The room is not set up for peeking.
The user has been banned from the room.
The room does not exist.

429	This request was rate-limited.
200 response
Name	Type	Description
chunk	[ClientEvent]	Required:

The thread roots, ordered by the latest_event in each event’s aggregation bundle. All events returned include bundled aggregations.

If the thread root event was sent by an ignored user, the event is returned redacted to the caller. This is to simulate the same behaviour of a client doing aggregation locally on the thread.


next_batch	string	A token to supply to from to keep paginating the responses. Not present when there are no further results.
ClientEvent
Name	Type	Description
content	object	Required: The body of this event, as created by the client which sent it.
event_id	string	Required: The globally unique identifier for this event.
origin_server_ts	integer	Required: Timestamp (in milliseconds since the unix epoch) on originating homeserver when this event was sent.
room_id	string	Required: The ID of the room associated with this event.
sender	string	Required: Contains the fully-qualified ID of the user who sent this event.
state_key	string	

Present if, and only if, this event is a state event. The key making this piece of state unique in the room. Note that it is often an empty string.

State keys starting with an @ are reserved for referencing user IDs, such as room members. With the exception of a few events, state events set with a given user’s ID as the state key MUST only be set by that user.


type	string	Required: The type of the event.
unsigned	UnsignedData	Contains optional extra information about the event.
UnsignedData
Name	Type	Description
age	integer	The time in milliseconds that has elapsed since the event was sent. This field is generated by the local homeserver, and may be incorrect if the local time on at least one of the two servers is out of sync, which can cause the age to either be negative or greater than it actually is.
prev_content	EventContent	The previous content for this event. This field is generated by the local homeserver, and is only returned if the event is a state event, and the client has permission to see the previous content.

Changed in v1.2: Previously, this field was specified at the top level of returned events rather than in unsigned (with the exception of the GET .../notifications endpoint), though in practice no known server implementations honoured this.
redacted_because	ClientEvent	The event that redacted this event, if any.
transaction_id	string	The client-supplied transaction ID, for example, provided via PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}, if the client being given the event is the same one which sent it.
{
  "chunk": [
    {
      "content": {
        "body": "This is an example text message",
        "format": "org.matrix.custom.html",
        "formatted_body": "<b>This is an example text message</b>",
        "msgtype": "m.text"
      },
      "event_id": "$143273582443PhrSn:example.org",
      "origin_server_ts": 1432735824653,
      "room_id": "!jEsUZKDJdhlrceRyVU:example.org",
      "sender": "@example:example.org",
      "type": "m.room.message",
      "unsigned": {
        "age": 1234
      }
    }
  ],
  "next_batch": "next_batch_token"
}

400 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_INVALID_PARAM",
  "error": "Unknown pagination token"
}

403 response
Error
Name	Type	Description
errcode	string	Required: An error code.
error	string	A human-readable error message.
{
  "errcode": "M_FORBIDDEN",
  "error": "You are not allowed to view this room."
}

429 response
RateLimitError
Name	Type	Description
errcode	string	Required: The M_LIMIT_EXCEEDED error code
error	string	A human-readable error message.
retry_after_ms	integer	The amount of time in milliseconds the client should wait before trying the request again.
{
  "errcode": "M_LIMIT_EXCEEDED",
  "error": "Too many requests",
  "retry_after_ms": 2000
}
