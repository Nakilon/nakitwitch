# 1. create app: https://dev.twitch.tv/console/apps/create
# 2. find <client_id> and create client_secret on apps properties page, save both
# 3. set OAuth Redirect URL: http://localhost:8000
# 4. obtain <auth code> by opening in web browser (edit or remove scopes as needed):
#    https://id.twitch.tv/oauth2/authorize?response_type=code&client_id=<client_id>&redirect_uri=http://localhost:8000&scope=chat:read+chat:edit+moderator:read:followers
# 5. get tokens:
#    $ curl https://id.twitch.tv/oauth2/token -d "client_id=$( \
#        cat twitch_client_id.secret.txt                       \
#      )&client_secret=$(                                      \
#        cat twitch_client_secret.secret.txt                   \
#      )&grant_type=authorization_code&code=<auth code>&redirect_uri=http://localhost:8000" \
#        >twitch.secret.json

require "nakischema"

module Twitch
  Error = ::Class.new ::RuntimeError

  def self.banword str
    str.
      gsub(/н(ег|иге)р/, "<censored>").
      gsub(/п[еи]д[ао]рас/, "<censored>")
  end

  def self.configure client_id, client_secret, tokens_filename
    @client_id = client_id
    @client_secret = client_secret
    @tokens_filename = tokens_filename
  end
  def self.refresh
    ::File.write @tokens_filename, ::NetHTTPUtils.request_data("https://id.twitch.tv/oauth2/token", :POST, form: {
      client_id: @client_id || raise(Error, "missing configuration (#{::Module.nesting}.configure)"),
      client_secret: @client_secret || raise(Error, "missing configuration (#{::Module.nesting}.configure)"),
      grant_type: "refresh_token",
      refresh_token: ::JSON.load(::File.read(@tokens_filename)).fetch("refresh_token")
    } )
  end

  SCHEMA = {
    "videos" => { hash: {
      "data" => {
        size: 0..1,
        each: { hash_req: {
        "user_id" => /\A[0-9]+\z/,
        "user_login" => /\A\S+\z/,
        "user_name" => /\S/,
        "title" => /\S/,
        "published_at" => /\A202\d-(0[1-9]|1[0-2])-([012][0-9]|3[01])T[012][0-9]:[0-5][0-9]:[0-5][0-9]Z\z/,
        "view_count" => 0..1000000000,
        } },
      },
      "pagination" => { hash: {} }
    } },
    "channels/followers" => { hash: {
      "total" => 0..1000000000,
      "data" => [[]],
      "pagination" => { hash: {} },
    } },
  }
  require "nethttputils"
  require "json"
  require "nakischema"
  def self.request mtd, retry_delay = 5, **form
    ::JSON.load( begin
      ::NetHTTPUtils.request_data "https://api.twitch.tv/helix/#{mtd}", form: form, header: {
        "Authorization" => "Bearer #{::JSON.load(::File.read(@tokens_filename)).fetch "access_token"}",
        "client-id" => @client_id || raise(Error, "missing configuration (#{::Module.nesting}.configure)")
      }
    rescue ::NetHTTPUtils::Error
      fail unless '{"error":"Unauthorized","status":401,"message":"Invalid OAuth token"}' == $!.body
      refresh
      sleep retry_delay
      retry
    end ).tap do |_|
      ::Nakischema.validate _, SCHEMA[mtd] if SCHEMA.key? mtd
    end
  end

  def self.login_to_id login
    request("users", "login" => login)["data"][0]["id"]
  end

end
