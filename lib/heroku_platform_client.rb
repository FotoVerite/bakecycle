require 'httparty'
require 'rendezvous'

class HerokuPlatformClient
  attr_reader :app

  include HTTParty
  base_uri 'https://api.heroku.com'

  def initialize(oauth_key, app)
    @app = app
    self.class.headers(
      'Accept' => 'application/vnd.heroku+json; version=3',
      'Authorization' => "Bearer #{oauth_key}"
    )
  end

  def latest_release
    resp = self.class.get(
      "/apps/#{app}/releases",
      headers: {
        'Range' => 'id ..; order=desc, max=1'
      }
    )
    raise "Error fetching latest release: #{response.body}" unless resp.success?
    resp.first
  end

  def restart_all
    self.class.delete("/apps/#{app}/dynos")
  end

  def run(cmd)
    opt = {
      body: {
        attach: "true",
        command: cmd
      }.to_json,
      headers: {
        'Content-Type' => 'application/json'
      }
    }
    response = self.class.post("/apps/#{app}/dynos", opt)
    session = Rendezvous.new(
      input: StringIO.new,
      output: StringIO.new,
      url: response['attach_url']
    )
    session.start
    session.output.rewind
    session.output.read
  end
end
