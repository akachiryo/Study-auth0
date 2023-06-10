class Auth0Controller < ApplicationController
  def callback
    auth_info = request.env['omniauth.auth']
    # ログを見てみましょう！
    p auth_info['credentials']['id_token']
    redirect_to root_path
  end

  def failure
    p request.params['message']
    redirect_to login_path
  end

  def logout
    request_params = {
      returnTo: login_url,
      client_id: ENV['AUTH_CLIENT_ID']
    }
    URI::HTTPS.build(host: ENV['AUTH_DOMAIN'], path: '/v2/logout', query: request_params.to_query).to_s
  end
end
