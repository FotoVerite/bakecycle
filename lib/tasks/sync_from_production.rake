# frozen_string_literal: true

# Pulls a copy of the production database into dev or staging.
#
# Production and staging are only reachable over SSH (see config/deploy/production.rb
# and config/deploy/staging.rb) -- there is no direct network route to either Postgres
# instance from a laptop. pg_dump runs on the production box itself (local socket auth,
# same as the deployed app uses) and is piped straight into pg_restore on the target,
# with the bytes only ever passing through this process -- nothing is written to disk
# on production or staging.
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

    dump_cmd = [
      "ssh", "-p", PRODUCTION_SSH_PORT.to_s, PRODUCTION_SSH,
      "pg_dump --no-owner --no-acl --exclude-table-data=versions -Fc #{PRODUCTION_DB}"
    ]

    # Drop only -- the dump's own TOC always includes a "CREATE SCHEMA public" entry,
    # so pre-creating it here would collide with that and pg_restore would report a
    # (harmless but exit-code-poisoning) "schema already exists" error.
    reset_schema_sql = "DROP SCHEMA public CASCADE;"

    restore_env = {}
    restore_args = ["pg_restore", "--no-owner", "--no-acl"]
    reset_cmd = nil

    if target == "staging"
      reset_cmd = ["ssh", STAGING_SSH, "psql -d #{STAGING_DB} -c \"#{reset_schema_sql}\""]
      restore_cmd = ["ssh", STAGING_SSH, "#{restore_args.join(' ')} -d #{STAGING_DB}"]
    else
      dev_config = ActiveRecord::Base.configurations.configs_for(env_name: "development", name: "primary")
                                      .configuration_hash
      restore_env["PGPASSWORD"] = dev_config[:password].to_s if dev_config[:password].present?

      conn_args = []
      conn_args += ["-h", dev_config[:host].to_s] if dev_config[:host].present?
      conn_args += ["-p", dev_config[:port].to_s] if dev_config[:port].present?
      conn_args += ["-U", dev_config[:username].to_s] if dev_config[:username].present?

      reset_cmd = [restore_env, "psql", *conn_args, "-d", local_db, "-c", reset_schema_sql]
      restore_cmd = [restore_env, *restore_args, *conn_args, "-d", local_db]
    end

    # pg_restore --clean doesn't topologically order DROP statements across cross-table
    # FK dependencies (e.g. a FK on another table referencing users_pkey blocks dropping
    # users first), so reset the target schema up front and restore into it empty instead.
    puts "Resetting #{target} schema..."
    raise "Schema reset on #{target} failed" unless system(*reset_cmd)

    puts "Dumping from production and restoring into #{target}..."
    dump_read, dump_write = IO.pipe
    dump_pid = Process.spawn(*dump_cmd, out: dump_write)
    dump_write.close

    restore_pid = Process.spawn(*restore_cmd, in: dump_read)
    dump_read.close

    _, dump_status = Process.wait2(dump_pid)
    _, restore_status = Process.wait2(restore_pid)

    raise "pg_dump on production failed (exit #{dump_status.exitstatus})" unless dump_status.success?
    raise "pg_restore into #{target} failed (exit #{restore_status.exitstatus})" unless restore_status.success?

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
