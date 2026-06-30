# frozen_string_literal: true

require "tempfile"

# Pulls a copy of the production database into dev or staging.
#
# Production and staging are only reachable over SSH (see config/deploy/production.rb
# and config/deploy/staging.rb) -- there is no direct network route to either Postgres
# instance from a laptop. pg_dump runs on the production box itself (local socket auth,
# same as the deployed app uses) and streams down into a local temp file on this
# machine -- nothing is written to disk on production or staging.
#
# The dump lands in a local temp file (rather than a live pipe) because the TOC has to
# be filtered in two passes -- see "extension entries" comment below -- which requires
# a seekable file, not a pipe.
#
# The PaperTrail `versions` table is excluded (schema kept, zero rows) via
# --exclude-table-data so dev/staging never end up with the multi-GB audit-trail
# backlog described in CLAUDE.md.
namespace :db do
  PRODUCTION_SSH = "deploy@97.107.141.39"
  PRODUCTION_SSH_PORT = 21500
  PRODUCTION_DB = "bakecycle_production"

  STAGING_SSH = "deploy@23.239.9.198"
  STAGING_DB = "bakecycle_staging"
  STAGING_RELEASE_PATH = "/home/deploy/apps/bakecycle_staging/current"

  desc "Sync production data into dev or staging, excluding the PaperTrail versions table (TARGET=development|staging)"
  task sync_from_production: :environment do
    target = ENV["TARGET"]
    unless %w[development staging].include?(target)
      raise "Usage: TARGET=development|staging rails db:sync_from_production"
    end

    local_db = target == "staging" ? STAGING_DB : (ENV["DB_NAME_DEVELOPMENT"] || "bakecycle_development")

    puts "This will OVERWRITE all data in '#{local_db}' (#{target}) with a copy of " \
         "production (#{PRODUCTION_DB}). The 'versions' table will be excluded (schema kept, no rows)."
    unless ENV["FORCE"] == "1"
      print "Type the target database name (#{local_db}) to confirm: "
      confirmation = $stdin.gets&.chomp
      raise "Aborted: confirmation did not match '#{local_db}'." unless confirmation == local_db
    end

    dump_file = Tempfile.new(["production_dump", ".pgdump"])
    dump_file.close

    begin
      dump_cmd = [
        "ssh", "-p", PRODUCTION_SSH_PORT.to_s, PRODUCTION_SSH,
        "pg_dump --no-owner --no-acl --exclude-table-data=versions -Fc #{PRODUCTION_DB}"
      ]

      reset_schema_sql = "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

      restore_env = {}
      conn_args = []

      if target == "staging"
        reset_cmd = ["ssh", STAGING_SSH, "psql -d #{STAGING_DB} -c \"#{reset_schema_sql}\""]
      else
        dev_config = ActiveRecord::Base.configurations.configs_for(env_name: "development", name: "primary")
                                        .configuration_hash
        restore_env["PGPASSWORD"] = dev_config[:password].to_s if dev_config[:password].present?
        conn_args += ["-h", dev_config[:host].to_s] if dev_config[:host].present?
        conn_args += ["-p", dev_config[:port].to_s] if dev_config[:port].present?
        conn_args += ["-U", dev_config[:username].to_s] if dev_config[:username].present?

        reset_cmd = [restore_env, "psql", *conn_args, "-d", local_db, "-c", reset_schema_sql]
      end

      # pg_restore --clean doesn't topologically order DROP statements across cross-table
      # FK dependencies (e.g. a FK on another table referencing users_pkey blocks dropping
      # users first), so reset the target schema up front and restore into it empty instead.
      puts "Resetting #{target} schema..."
      raise "Schema reset on #{target} failed" unless system(*reset_cmd)

      puts "Dumping from production to local temp file..."
      raise "pg_dump on production failed" unless system(*dump_cmd, out: dump_file.path)

      # pg_dump always includes CREATE EXTENSION / COMMENT ON EXTENSION entries for
      # plpgsql and pg_stat_statements. The deploy role isn't a superuser on dev/staging,
      # so those entries fail with permission errors on restore -- harmless (the
      # extensions already exist on the target) but they poison pg_restore's exit code.
      # Filter them out of the TOC before restoring.
      toc = IO.popen(["pg_restore", "-l", dump_file.path], &:read)
      raise "Failed to read dump TOC" unless $?.success?

      filtered_toc = Tempfile.new(["production_dump_toc", ".list"])
      begin
        filtered_toc.write(toc.lines.reject { |line| line.include?(" EXTENSION ") }.join)
        filtered_toc.close

        sql_file = Tempfile.new(["production_restore", ".sql"])
        sql_file.close
        begin
          puts "Generating restore script from dump..."
          gen_cmd = ["pg_restore", "--no-owner", "--no-acl", "-L", filtered_toc.path, "-f", sql_file.path, dump_file.path]
          raise "Failed to generate restore script from dump" unless system(*gen_cmd)

          puts "Restoring into #{target}..."
          restore_cmd =
            if target == "staging"
              ["ssh", STAGING_SSH, "psql -v ON_ERROR_STOP=1 -d #{STAGING_DB}"]
            else
              [restore_env, "psql", "-v", "ON_ERROR_STOP=1", *conn_args, "-d", local_db]
            end

          raise "Restore into #{target} failed" unless system(*restore_cmd, in: sql_file.path)
        ensure
          sql_file.unlink
        end
      ensure
        filtered_toc.unlink
      end
    ensure
      dump_file.unlink
    end

    puts "Done. '#{local_db}' (#{target}) now mirrors production (versions table empty)."

    puts "Running db:migrate against #{target}..."
    migrate_cmd =
      if target == "staging"
        ["ssh", STAGING_SSH, "cd #{STAGING_RELEASE_PATH} && RAILS_ENV=staging bin/rails db:migrate"]
      else
        [{ "RAILS_ENV" => "development" }, "bin/rails", "db:migrate"]
      end
    raise "db:migrate against #{target} failed" unless system(*migrate_cmd)
  end
end
