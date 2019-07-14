# frozen_string_literal: true

class SqlMigrationGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  desc 'This generator creates sql migration files at db/migrate'
  def create_sql_migration_files
    say_status :invoke, :active_record, :white

    raise(ActiveRecord::IllegalMigrationNameError, file_name) unless /^[_a-z0-9]+$/.match?(file_name)

    timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
    up_migration = "db/migrate/#{timestamp}_#{file_name}.up.sql"
    down_migration = "db/migrate/#{timestamp}_#{file_name}.down.sql"

    existing_migrations = Rails.root.join('db/migrate').glob("*_#{file_name}.{rb,{up,down}.sql}")
    if existing_migrations.empty?
      create_file up_migration
      create_file down_migration

    elsif existing_migrations.all? { |x| x.to_s.end_with?('.sql') } &&
          existing_migrations.count == 2 &&
          existing_migrations.map(&:read).all?(&:empty?)

      say_status :identical, up_migration, :blue
      say_status :identical, down_migration, :blue

    elsif (ARGV & %w[--skip -s]).any?
      say_status :skip, up_migration, :yellow
      say_status :skip, down_migration, :yellow

    elsif (ARGV & %w[--force -f]).any?
      existing_migrations.each { |file| file.delete; say_status :remove, file, :green }
      create_file up_migration
      create_file down_migration

    else
      say_status :conflict, up_migration, :red
      say_status :conflict, down_migration, :red
      raise Thor::Error, "Another migration is already named #{file_name}: " \
                "#{existing_migrations.first}. Use --force to replace this migration " \
                'or --skip to ignore conflicted file.'
    end
  end
end
