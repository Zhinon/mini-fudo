module AppConfig
    ADMIN_API_KEY = ENV.fetch('ADMIN_API_KEY')
    DB_HOST       = ENV.fetch('DB_HOST', 'postgres')
    DB_USER       = ENV.fetch('DB_USER', 'fudo')
    DB_PASS       = ENV.fetch('DB_PASS', 'secret')
    DB_NAME       = ENV.fetch('DB_NAME', 'fudo')
    SECRET_KEY    = ENV.fetch('JWT_SECRET')
    INTERNAL_API_SECRET = ENV.fetch('INTERNAL_API_SECRET')
end
