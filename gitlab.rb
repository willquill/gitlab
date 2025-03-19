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

