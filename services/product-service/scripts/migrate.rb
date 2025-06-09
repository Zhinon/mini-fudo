require_relative '../config/boot'
require 'sequel'
require 'db'

Sequel.extension :migration
Sequel::Migrator.run(DB, 'db/migrations')
