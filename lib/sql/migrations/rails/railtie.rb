# frozen_string_literal: true

module Sql
  module Migrations
    module Rails
      TMP_MIGRATIONS_FOLDER = 'tmp/sql_migrations/migrate'
      LAST_UPDATE_FILE = 'tmp/sql_migrations/last_update.json'

      class Railtie < ::Rails::Railtie
        initializer :load_sql_migrations do
          delete_extra_migrations!
          generate_tmp_migrations!
          update_data_file!
          update_rails_migration_paths!
        end

        # Data about the previous files state
        # This is needed for rebuild only modified temporary migrations
        def last_update
          @last_update ||= begin
            file = ::Rails.root.join(Sql::Migrations::Rails::LAST_UPDATE_FILE).tap { |x| x.dirname.mkpath }
            file.file? ? JSON.parse(file.read).transform_keys(&:to_sym) : { timestamp: '0', files: {} }
          end
        end

        def tmp_migrations_path
          @tmp_migrations_path ||= ::Rails.root.join(Sql::Migrations::Rails::TMP_MIGRATIONS_FOLDER).tap(&:mkpath)
        end

        def sql_migrations
          @sql_migrations ||= ::Rails.root.join('db/migrate').glob('*.{up,down}.sql')
                                     .group_by { |x| x.basename('.up.sql').basename('.down.sql') }
        end

        def modified_sql_migrations
          @modified_sql_migrations ||= sql_migrations.select do |name, paths|
            last_update[:files][name.to_s] != paths.map { |x| x.to_s.split('.')[-2] } ||
              paths.map { |x| [x.mtime, x.ctime] }.flatten.map(&:utc)
                   .max.strftime('%Y%m%d%H%M%S') > last_update[:timestamp]
          end
        end

        def delete_extra_migrations!
          tmp_migrations_path.children.select { |x| sql_migrations.keys.exclude?(x.basename('.rb')) }.each(&:delete)
        end

        def generate_tmp_migrations!
          template = File.read(File.join(File.dirname(__FILE__), 'templates/migration.rb.tt'))
          modified_sql_migrations.each do |name, paths|
            erb_hash = {
              migration_class_name: name.to_s.split('_', 2).second.camelize,
              up_migration: paths.find { |x| x.to_s.end_with?('.up.sql') },
              down_migration: paths.find { |x| x.to_s.end_with?('.down.sql') }
            }

            erb_result = ERB.new(template, nil, '-').result_with_hash(erb_hash)
            Pathname(tmp_migrations_path.join("#{name}.rb")).write(erb_result)
          end
        end

        def update_data_file!
          data = {
            timestamp: Time.now.utc.strftime('%Y%m%d%H%M%S'),
            files: sql_migrations.transform_values { |x1| x1.map { |x2| x2.to_s.split('.')[-2] } }
          }.to_json

          ::Rails.root.join(Sql::Migrations::Rails::LAST_UPDATE_FILE).write(data)
        end

        def update_rails_migration_paths!
          ::Rails.application.config.paths['db/migrate'] << Sql::Migrations::Rails::TMP_MIGRATIONS_FOLDER
        end
      end
    end
  end
end
