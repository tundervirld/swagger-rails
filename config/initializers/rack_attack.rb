class Rack::Attack
  # `Rack::Attack` is configured to use the `Rails.cache` value by default,
  # but you can override that by setting the `Rack::Attack.cache.store` value
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Allow all local traffic
  # Excluir de la protección a la IP local
  # Always allow requests from localhost
  # (blocklist & throttles are skipped)
  self.safelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Allow an IP address to make 5 requests every 5 seconds
  # Permitir hasta 5 llamadas en 1sg, para la misma IP
  self.throttle('req/ip', limit: 5, period: 1) do |req|
    req.ip
  end

  # Send the following response to throttled clients
  # Mensaje  de respuesta para el cliente que esta realizando muchas llamadas a la API.
  self.throttled_response = lambda do |env|
    now = Time.now
    match_data = env['rack.attack.match_data']
    retry_after = (match_data || {})[:period]
    rate_limit_reset =  (now + (match_data[:period] - now.to_i % match_data[:period]))

    headers = {
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => rate_limit_reset.to_s,
      'Content-Type' => 'application/json',
      'Retry-After' => retry_after.to_s
    }

    [ 429, headers, [
      {:error => "Throttle limit reached. Retry later."}.to_json
      ]
    ]
  end
end