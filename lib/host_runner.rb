# Copyright (c) 2013-2014 SUSE LLC
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact SUSE LLC.
#
# To contact SUSE about this file by physical or electronic mail,
# you may find current contact information at www.suse.com

class HostRunner
  def initialize(host_name, host_config)
    @host_name = host_name
    config_file = host_config.config_file

    host = host_config.host(host_name)
    if !host
      raise InvalidHostError.new("Host '#{host_name}' is not defined in '#{config_file}'")
    end

    @ip = host["address"]
    @base_snapshot_id = host["base_snapshot_id"]
    if !@ip
      raise InvalidHostError.new(
        "Missing 'address' field for host '#{host_name}' in '#{config_file}'"
      )
    end
    if !@base_snapshot_id && !ENV["SKIP_CLEANUP"]
      raise InvalidHostError.new(
        "Missing 'base_snapshot_id' field for host '#{host_name}' in '#{config_file}'"
      )
    end

    @locker = LockService.new(host_config.lock_server_address)
  end

  def start
    if !@locker.request_lock(@host_name)
      raise LockError.new("Host '#{@host_name}' already locked")
    end

    connect
    check_cleanup_capabilities if !ENV["SKIP_CLEANUP"]

    @ip
  end

  def cleanup
    remote = RemoteCommandRunner.new(@ip)
    remote.run "snapper", "create", "-c", "number", "--pre-number", @base_snapshot_id.to_s,
      "--description", "pennyworth_snapshot"
    remote.run "snapper", "undochange", "#{@base_snapshot_id}..0"
    remote.run "bash", "-c", "reboot &"
  end

  def stop
    if @connected && !ENV["SKIP_CLEANUP"]
      cleanup
    end
    @locker.release_lock(@host_name)
  end

  private

  # Makes sure the we can connect to the remote system as root (without a
  # password or passphrase)
  def connect
    Cheetah.run "ssh", "-q", "-o", "BatchMode=yes", "root@#{@ip}"
  rescue Cheetah::ExecutionFailed
    raise SshConnectionFailed.new(
      "Could not establish SSH connection to host '#{@ip}'. Please make sure that " \
      "you can connect non-interactively as root, e.g. using ssh-agent.\n\n" \
      "To copy your default ssh key to the machine run:\n" \
      "ssh-copy-id root@#{@ip}"
    )
  end

  def check_cleanup_capabilities
    begin
      RemoteCommandRunner.new(@ip).run "snapper", "--help"
    rescue Cheetah::ExecutionFailed
      raise CommandNotFoundError.new(
        "Snapper needs to be installed on the test system '#{@ip}' for the automatic cleanup."
      )
    end
    @connected = true
  end
end
