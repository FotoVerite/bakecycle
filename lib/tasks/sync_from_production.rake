# frozen_string_literal: true

require "tempfile"

# Pulls a copy of the production database into dev or staging.
#
# Production and staging are only reachable over SSH (see config/deploy/production.rb
# and config/deploy/staging.rb) -- there is no direct network route to either Postgres
# instance from a laptop. pg_dump runs on the production box itself (local socket auth,
# same as the deployed app uses) and is piped straight into pg_restore on the target,
# with the bytes only ever passing through this process's memory in transit -- nothing
# is written to disk on production, staging, or this laptop.
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

  # Staging activates Ruby via mise from ~/.bashrc (`eval "$(mise activate bash)"`), but
  # `ssh host "command"` runs bash non-interactively, and ~/.bashrc on this box starts
  # with the standard `case $- in *i*) ;; *) return;; esac` guard that skips the rest of
  # the file (including the mise line) for any non-interactive shell -- so `source
  # ~/.bashrc` from here is a no-op and `ruby`/`bin/rails` stay off PATH. Prepending the
  # mise shims dir directly bypasses .bashrc entirely and actually works (verified).
  # Production doesn't need this -- its system Ruby is already on PATH for non-
  # interactive SSH commands. Any new staging command that runs `bin/rails` should be
  # prefixed with this.
  STAGING_SHELL_SETUP = 'export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"'

  # pg_dump always includes CREATE EXTENSION / COMMENT ON EXTENSION entries for
  # plpgsql and pg_stat_statements. The deploy role isn't a superuser on dev/staging, so
  # those two specifically fail with permission errors on restore -- harmless (plpgsql
  # already exists on the target; pg_stat_statements isn't referenced by the schema).
  # Other extensions (e.g. uuid-ossp, "trusted" since PG13 and restorable without
  # superuser) restore fine and must NOT be treated as benign -- schema objects can
  # depend on their functions (e.g. a column default calling uuid_generate_v4()), so
  # treating a real failure there as harmless would silently corrupt the restore.
  def benign_restore_error?(error_line)
    # pg_restore's live error text uses lowercase ("must be owner of extension
    # plpgsql", "permission denied to create extension \"pg_stat_statements\"") --
    # NOT the uppercase "EXTENSION" token from `pg_restore -l` TOC listings, which
    # this code path doesn't use. Match case-insensitively against the real format.
    downcased = error_line.downcase
    return false unless downcased.include?("extension")

    %w[plpgsql pg_stat_statements].any? { |ext| downcased.include?(ext) }
  end

  def with_elapsed_time(label)
    started_at = Time.zone.now
    puts "--- #{label} ---"
    yield
    puts format("--- #{label} done (%.1fs) ---", Time.zone.now - started_at)
  end

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

    overall_started_at = Time.zone.now

    # --verbose makes both ends print one line per object (table/index/sequence/etc.)
    # as they're processed, instead of sitting silent for the whole transfer.
    dump_cmd = [
      "ssh", "-p", PRODUCTION_SSH_PORT.to_s, PRODUCTION_SSH,
      "pg_dump --no-owner --no-acl --verbose --exclude-table-data=versions -Fc #{PRODUCTION_DB}"
    ]

    reset_schema_sql = "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

    restore_env = {}
    conn_args = []

    if target == "staging"
      reset_cmd = ["ssh", STAGING_SSH, "psql -d #{STAGING_DB} -c \"#{reset_schema_sql}\""]
      restore_cmd = ["ssh", STAGING_SSH, "pg_restore --no-owner --no-acl --verbose -d #{STAGING_DB}"]
    else
      dev_config = ActiveRecord::Base.configurations.configs_for(env_name: "development", name: "primary")
        .configuration_hash
      restore_env["PGPASSWORD"] = dev_config[:password].to_s if dev_config[:password].present?
      conn_args += ["-h", dev_config[:host].to_s] if dev_config[:host].present?
      conn_args += ["-p", dev_config[:port].to_s] if dev_config[:port].present?
      conn_args += ["-U", dev_config[:username].to_s] if dev_config[:username].present?

      reset_cmd = [restore_env, "psql", *conn_args, "-d", local_db, "-c", reset_schema_sql]
      restore_cmd = [restore_env, "pg_restore", "--no-owner", "--no-acl", "--verbose", *conn_args, "-d", local_db]
    end

    # pg_restore --clean doesn't topologically order DROP statements across cross-table
    # FK dependencies (e.g. a FK on another table referencing users_pkey blocks dropping
    # users first), so reset the target schema up front and restore into it empty instead.
    # The dump's own TOC also has a "CREATE SCHEMA public" entry, so recreating it here
    # causes one harmless "already exists" error during restore -- it's filtered out
    # below alongside the extension-permission errors, not treated as fatal.
    with_elapsed_time("Resetting #{target} schema") do
      raise "Schema reset on #{target} failed" unless system(*reset_cmd)
    end

    dump_status = restore_status = restore_stderr = nil
    with_elapsed_time("Dumping from production and restoring into #{target}") do
      dump_read, dump_write = IO.pipe
      dump_pid = Process.spawn(*dump_cmd, out: dump_write)
      dump_write.close

      restore_err_read, restore_err_write = IO.pipe
      restore_pid = Process.spawn(*restore_cmd, in: dump_read, err: restore_err_write)
      dump_read.close
      restore_err_write.close

      # --verbose output streams here live (prefixed so it's distinguishable from this
      # task's own progress lines) while every line is also captured for the benign-vs-
      # fatal error classification once the restore finishes.
      restore_stderr = +""
      stderr_thread = Thread.new do
        restore_err_read.each_line do |line|
          restore_stderr << line
          puts "  [restore] #{line.chomp}" if line.start_with?("pg_restore:")
        end
      end

      _, dump_status = Process.wait2(dump_pid)
      _, restore_status = Process.wait2(restore_pid)
      stderr_thread.join
      restore_err_read.close
    end

    raise "pg_dump on production failed (exit #{dump_status.exitstatus})" unless dump_status.success?

    unless restore_status.success?
      error_lines = restore_stderr.lines.grep(/^pg_restore: error:/)
      fatal_lines = error_lines.reject do |line|
        benign_restore_error?(line) || line.include?('schema "public" already exists')
      end

      unless fatal_lines.empty?
        warn restore_stderr
        raise "Restore into #{target} failed (exit #{restore_status.exitstatus})"
      end

      puts "Restore into #{target} completed with only known-benign warnings " \
           "(already shown above as [restore] lines)."
    end

    puts "'#{local_db}' (#{target}) now mirrors production (versions table empty)."

    with_elapsed_time("Running db:migrate against #{target}") do
      migrate_cmd =
        if target == "staging"
          ["ssh", STAGING_SSH,
           "#{STAGING_SHELL_SETUP} && cd #{STAGING_RELEASE_PATH} && RAILS_ENV=staging bin/rails db:migrate"]
        else
          [{ "RAILS_ENV" => "development" }, "bin/rails", "db:migrate"]
        end
      raise "db:migrate against #{target} failed" unless system(*migrate_cmd)
    end

    Rake::Task["db:sync_bakery_logos"].invoke if target == "staging"

    puts format("Done. Total time: %.1fs", Time.zone.now - overall_started_at)
  end

  desc "Sync staging data into dev, excluding the PaperTrail versions table"
  task sync_from_staging: :environment do
    local_db = ENV["DB_NAME_DEVELOPMENT"] || "bakecycle_development"

    puts "This will OVERWRITE all data in '#{local_db}' (development) with a copy of " \
         "staging (#{STAGING_DB}). The 'versions' table will be excluded (schema kept, no rows)."
    unless ENV["FORCE"] == "1"
      print "Type the target database name (#{local_db}) to confirm: "
      confirmation = $stdin.gets&.chomp
      raise "Aborted: confirmation did not match '#{local_db}'." unless confirmation == local_db
    end

    overall_started_at = Time.zone.now

    dump_cmd = [
      "ssh", STAGING_SSH,
      "pg_dump --no-owner --no-acl --verbose --exclude-table-data=versions -Fc #{STAGING_DB}"
    ]

    reset_schema_sql = "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

    dev_config = ActiveRecord::Base.configurations.configs_for(env_name: "development", name: "primary")
      .configuration_hash
    restore_env = {}
    conn_args = []
    restore_env["PGPASSWORD"] = dev_config[:password].to_s if dev_config[:password].present?
    conn_args += ["-h", dev_config[:host].to_s] if dev_config[:host].present?
    conn_args += ["-p", dev_config[:port].to_s] if dev_config[:port].present?
    conn_args += ["-U", dev_config[:username].to_s] if dev_config[:username].present?

    # Staging runs Postgres 16 (Ubuntu); this laptop's linked `pg_restore` is 14, which
    # can't read v16's custom-dump archive format ("unsupported version (1.15) in file
    # header"). Use the unlinked postgresql@16 keg's pg_restore explicitly instead of
    # switching the system-wide link (would affect the running v14 server/other tasks).
    pg_restore_bin = "/opt/homebrew/opt/postgresql@16/bin/pg_restore"
    pg_restore_bin = "pg_restore" unless File.executable?(pg_restore_bin)

    reset_cmd = [restore_env, "psql", *conn_args, "-d", local_db, "-c", reset_schema_sql]
    restore_cmd = [restore_env, pg_restore_bin, "--no-owner", "--no-acl", "--verbose", *conn_args, "-d", local_db]

    with_elapsed_time("Resetting development schema") do
      raise "Schema reset on development failed" unless system(*reset_cmd)
    end

    dump_status = restore_status = restore_stderr = nil
    with_elapsed_time("Dumping from staging and restoring into development") do
      dump_read, dump_write = IO.pipe
      dump_pid = Process.spawn(*dump_cmd, out: dump_write)
      dump_write.close

      restore_err_read, restore_err_write = IO.pipe
      restore_pid = Process.spawn(*restore_cmd, in: dump_read, err: restore_err_write)
      dump_read.close
      restore_err_write.close

      restore_stderr = +""
      stderr_thread = Thread.new do
        restore_err_read.each_line do |line|
          restore_stderr << line
          puts "  [restore] #{line.chomp}" if line.start_with?("pg_restore:")
        end
      end

      _, dump_status = Process.wait2(dump_pid)
      _, restore_status = Process.wait2(restore_pid)
      stderr_thread.join
      restore_err_read.close
    end

    raise "pg_dump on staging failed (exit #{dump_status.exitstatus})" unless dump_status.success?

    unless restore_status.success?
      error_lines = restore_stderr.lines.grep(/^pg_restore: error:/)
      fatal_lines = error_lines.reject do |line|
        benign_restore_error?(line) || line.include?('schema "public" already exists')
      end

      unless fatal_lines.empty?
        warn restore_stderr
        raise "Restore into development failed (exit #{restore_status.exitstatus})"
      end

      puts "Restore into development completed with only known-benign warnings " \
           "(already shown above as [restore] lines)."
    end

    puts "'#{local_db}' (development) now mirrors staging (versions table empty)."

    with_elapsed_time("Running db:migrate against development") do
      migrate_cmd = [{ "RAILS_ENV" => "development" }, "bin/rails", "db:migrate"]
      raise "db:migrate against development failed" unless system(*migrate_cmd)
    end

    puts format("Done. Total time: %.1fs", Time.zone.now - overall_started_at)
  end

  # Only the Bakery#logo attachment is copied -- NOT the whole S3 bucket, which also
  # holds every generated invoice/export PDF (FileExport). Pulling the entire bucket
  # would dump production's invoice history into staging for no reason. Both legs run
  # on the box that already owns the relevant credentials (production's real AWS keys
  # never get pulled out to this laptop, staging's never get pushed in) -- this script
  # just relays bytes between the two SSH connections in a simple length-prefixed
  # framing: "KEY <path_bytesize> <body_bytesize>\n" + raw path bytes + raw body bytes,
  # repeated per object.
  desc "Copy bakery logo objects (only) from production's S3 bucket into staging's"
  task sync_bakery_logos: :environment do
    export_script = <<~'RUBY'
      STYLES = [:original, :invoice, :thumb].freeze
      $stdout.sync = true
      $stdout.binmode
      count = 0
      Bakery.where.not(logo_file_name: nil).find_each do |bakery|
        STYLES.each do |style|
          path = bakery.logo.path(style)
          next if path.nil?

          begin
            body = bakery.logo.s3_object(style).get.body.read
          rescue Aws::S3::Errors::NoSuchKey
            next
          end

          $stdout.write("KEY #{path.bytesize} #{body.bytesize}\n")
          $stdout.write(path)
          $stdout.write(body)
          count += 1
        end
      end
      warn "Exported #{count} logo objects from production"
    RUBY

    import_script = <<~'RUBY'
      $stdin.binmode
      s3_credentials = Paperclip::Attachment.default_options[:s3_credentials]
      client = Aws::S3::Client.new(
        region: Paperclip::Attachment.default_options[:s3_region],
        access_key_id: s3_credentials[:access_key_id],
        secret_access_key: s3_credentials[:secret_access_key]
      )
      bucket = s3_credentials[:bucket]
      count = 0
      while (header = $stdin.gets)
        match = header.match(/\AKEY (\d+) (\d+)\n\z/)
        raise "Bad frame: #{header.inspect}" unless match

        path = $stdin.read(match[1].to_i)
        body = $stdin.read(match[2].to_i)
        client.put_object(bucket: bucket, key: path.sub(%r{\A/}, ""), body: body)
        count += 1
      end
      warn "Uploaded #{count} logo objects to staging bucket #{bucket}"
    RUBY

    export_script_file = Tempfile.new(["bakery_logo_export", ".rb"])
    export_script_file.write(export_script)
    export_script_file.close

    import_script_file = Tempfile.new(["bakery_logo_import", ".rb"])
    import_script_file.write(import_script)
    import_script_file.close

    logo_dump = Tempfile.new(["bakery_logos", ".bin"])
    logo_dump.close

    begin
      puts "Exporting bakery logos from production..."
      export_cmd = [
        "ssh", "-p", PRODUCTION_SSH_PORT.to_s, PRODUCTION_SSH,
        "cd /var/www/bakecycle_production/current && RAILS_ENV=production bin/rails runner -"
      ]
      raise "Logo export from production failed" unless system(*export_cmd, in: export_script_file.path,
                                                                            out: logo_dump.path)

      # The import script needs stdin free for the binary logo payload, so (unlike the
      # export side) it can't be fed to `bin/rails runner -` itself -- that form reads
      # the whole of stdin as the script source, leaving nothing for the script's own
      # reads. Write it to a remote temp file first and run it from a path instead.
      remote_script_path = "/tmp/bakery_logo_import_#{Process.pid}.rb"
      write_script_cmd = ["ssh", STAGING_SSH, "cat > #{remote_script_path}"]
      raise "Failed to write import script to staging" unless system(*write_script_cmd, in: import_script_file.path)

      begin
        puts "Importing bakery logos into staging..."
        import_cmd = [
          "ssh", STAGING_SSH,
          "#{STAGING_SHELL_SETUP} && cd #{STAGING_RELEASE_PATH} && " \
            "RAILS_ENV=staging bin/rails runner #{remote_script_path}"
        ]
        raise "Logo import into staging failed" unless system(*import_cmd, in: logo_dump.path)
      ensure
        system("ssh", STAGING_SSH, "rm -f #{remote_script_path}")
      end
    ensure
      export_script_file.unlink
      import_script_file.unlink
      logo_dump.unlink
    end
  end
end
