root = File.expand_path('..', __dir__)
$LOAD_PATH.unshift "#{root}/config"
$LOAD_PATH.unshift "#{root}/infrastructure"

require 'sequel'
require 'db'

DB = Infrastructure::Database.connect

Sequel.extension :migration
Sequel::Migrator.run(DB, 'db/migrations')
