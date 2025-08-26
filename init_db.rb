#!/usr/bin/env ruby

# Vibe-coded
# Database initialization script for SQLite
# This script will create the database schema and import data

require_relative 'config/application'

puts "Initializing SQLite database..."

# Auto-migrate will create all tables based on model definitions
puts "Creating database schema..."
DataMapper.auto_migrate!

puts "Database schema created successfully!"

# Now let's import the data from the SQL dump
# We'll need to convert MySQL-specific syntax to SQLite-compatible syntax
puts "Importing data from SQL dump..."

require 'sqlite3'

# Connect to SQLite database directly
db_path = ENV['DATABASE_URL'].sub('sqlite://', '')
db = SQLite3::Database.new(db_path)

# Read and process the MySQL dump
sql_content = File.read('prueba_tecnica.sql')

# Extract INSERT statements and convert them for SQLite
insert_statements = sql_content.scan(/INSERT INTO `([^`]+)` VALUES (.+?);/m)

insert_statements.each do |table, values|
  puts "Importing data into #{table}..."
  # Convert MySQL backticks to SQLite standard
  sqlite_insert = "INSERT INTO #{table} VALUES #{values};"
  begin
    db.execute(sqlite_insert)
  rescue SQLite3::SQLException => e
    puts "Warning: Could not insert into #{table}: #{e.message}"
  end
end

db.close

puts "Database initialization complete!"
puts "SQLite database is ready at: #{db_path}"
