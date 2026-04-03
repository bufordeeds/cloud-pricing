Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"
    resource "/api/*",
      headers: %w[Authorization],
      methods: [ :get, :options, :head ],
      max_age: 3600
  end
end
