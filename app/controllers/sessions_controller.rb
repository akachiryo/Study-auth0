class SessionsController < ApplicationController
  require 'auth0'
  require 'uri'
  require 'cgi'
  require 'net/http'
  require 'openssl'

  #ログインページ
  def new
  end

  #ログイン処理
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    
    # ここから Auth0 API を叩く
    domain = ENV['AUTH0_DOMAIN']
    client_id = ENV['AUTH0_CLIENT_ID']
    client_secret = ENV['AUTH0_CLIENT_SECRET']
    # get access token
    url = URI("https://#{domain}/oauth/token")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request.body = "grant_type=client_credentials&client_id=#{client_id}"
    request.body << "&client_secret=#{client_secret}&audience=https://#{domain}/api/v2/"
    response = http.request(request)


    access_token = JSON.parse(response.read_body)["access_token"]
    # debugger
    client = Auth0Client.new(
      client_id: client_id,
      client_secret: client_secret,
      domain: domain,
      token: access_token,
      api_version: 2,
      timeout: 15
    )
    # auth0 gem のメソッド
    # https://www.rubydoc.info/gems/auth0/Auth0/Api/V2/Users#create_user-instance_method
    options = {fields: "email", include_fields: true}
    result = client.users_by_email(user.email, options)
    p result # ログを見てみましょう

    if user.email == result[0]['email'] #ここでRailsDBとAuth0DBの両方の値を確認してます。
      if user && user.authenticate(params[:session][:password])
        session[:user_id] = user.id
        #redirect_to root_path
        #redirect_post('/auth/auth0', params: { prompt: 'login' }, options: { method: :post, authenticity_token: 'auto' })
        p "ログイン成功"
        redirect_to root_path
      end
    else
      p "ログイン失敗"
      redirect_to login_path
    end 
  end
  
  #ログアウト処理
  def destroy
    session.delete(:user_id)
    redirect_to root_path
  end
end
