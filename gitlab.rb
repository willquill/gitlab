external_url ENV['GITLAB_EXTERNAL_URL']

# We do this because the external url has https
# and we are behind a reverse proxy that handles SSL termination
nginx['listen_port'] = 80
nginx['listen_https'] = false
nginx['redirect_http_to_https'] = false
nginx['proxy_set_headers'] = {
  "X-Forwarded-Proto" => "http",
}

gitlab_rails['lfs_enabled'] = true
gitlab_rails['initial_root_password'] = File.read('/run/secrets/initial_root_password').gsub("\n", "")
# Email setup
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = ENV['SMTP_ADDRESS']
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = ENV['SMTP_USER_NAME']
gitlab_rails['smtp_password'] = File.read('/run/secrets/smtp_password').gsub("\n", "")
gitlab_rails['smtp_domain'] = ENV['SMTP_DOMAIN']
gitlab_rails['smtp_authentication'] = 'login'
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = ENV['EMAIL_FROM']
gitlab_rails['gitlab_email_display_name'] = ENV['EMAIL_DISPLAY_NAME']
gitlab_rails['gitlab_email_reply_to'] = ENV['EMAIL_REPLY_TO']
gitlab_rails['gitlab_email_subject_suffix'] = " [GitLab]"
gitlab_rails['gitlab_root_email'] = ENV['GITLAB_ROOT_EMAIL']
package['modify_kernel_parameters'] = false

# OpenID Connect auth to authenticate Authentik users
gitlab_rails['omniauth_allow_single_sign_on'] = ['openid_connect']
gitlab_rails['omniauth_sync_email_from_provider'] = 'openid_connect'
gitlab_rails['omniauth_sync_profile_from_provider'] = ['openid_connect']
gitlab_rails['omniauth_sync_profile_attributes'] = ['email']
gitlab_rails['omniauth_auto_sign_in_with_provider'] = 'openid_connect'
gitlab_rails['omniauth_auto_link_saml_user'] = true
gitlab_rails['omniauth_auto_link_user'] = ["openid_connect"]
gitlab_rails['omniauth_providers'] = [
  {
    name: 'openid_connect',
    label: ENV['OIDC_LABEL'],
    args: {
      name: 'openid_connect',
      scope: ['openid','profile','email'],
      response_type: 'code',
      issuer: ENV['OIDC_ISSUER'],
      discovery: true,
      client_auth_method: 'query',
      uid_field: 'preferred_username',
      send_scope_to_token_endpoint: 'true',
      pkce: true,
      client_options: {
        identifier: ENV['OIDC_CLIENT_ID'],
        secret: ENV['OIDC_CLIENT_SECRET'],
        redirect_uri: ENV['OIDC_REDIRECT_URI'],
        # Authentik users in the "GitLab Admins" group
        # will be granted admin access in GitLab
        # (should work but didn't actually work for me)
        gitlab: {
          groups_attribute: "groups",
          admin_groups: ["GitLab Admins"]
        }
      },
      # For users signing in with this provider you configure,
      # the GitLab username will be set to the "sub" received from the provider
      # For my provider, this is the "email" claim
      gitlab_username_claim: 'preferred_username'
    }
  }
]
# Disables sign-in with username and password
# gitlab_rails['gitlab_signin_enabled'] = false DOESN'T WORK?

# CAUTION!
# This allows users to sign in without having a user account first. Define the allowed providers
# using an array, for example, ["saml", "google_oauth2"], or as true/false to allow all providers or none.
# User accounts will be created automatically when authentication was successful.
gitlab_rails['omniauth_allow_single_sign_on'] = ["openid_connect"]
gitlab_rails['omniauth_block_auto_created_users'] = false
# This links the OIDC user to the GitLab user
# gitlab_rails['omniauth_auto_link_user'] = ['openid_connect']

# LDAP to populate users
# gitlab_rails['ldap_enabled'] = true
# gitlab_rails['ldap_servers'] = {
#   'main' => {
#     'label' => 'LDAP',
#     'host' =>  'ldap.mydomain.com',
#     'port' => 636,
#     'uid' => 'sAMAccountName',
#     'bind_dn' => 'CN=Gitlab,OU=Users,DC=domain,DC=com',
#     'password' => '<bind_user_password>',
#     'encryption' => 'simple_tls',
#     'verify_certificates' => true,
#     'timeout' => 10,
#     'active_directory' => false,
#     'user_filter' => '(employeeType=developer)',
#     'base' => 'dc=example,dc=com',
#     'lowercase_usernames' => 'false',
#     'retry_empty_result_with_codes' => [80],
#     'allow_username_or_email_login' => false,
#     'block_auto_created_users' => false
#   }
# }
