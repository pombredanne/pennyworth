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

class CliHostController
  def initialize(config_dir, output)
    @config_dir = config_dir
    @out = output
  end

  def setup(url)
    if !url
      raise GLI::BadCommandLine.new("Please provide a URL argument")
    end

    @out.puts "Setup from '#{url}'"
    begin
      HostConfig.new(@config_dir).fetch(url)
    rescue HostFileError => e
      @out.puts "Error: #{e}"
    end
  end

  def list
    host_config = HostConfig.new(@config_dir)
    host_config.read
    host_config.hosts.each do |host|
      @out.puts host
    end
  end

  def lock(host_name)
    if !host_name
      raise GLI::BadCommandLine.new("Please provide a host name argument")
    end

    @out.puts "Lock host '#{host_name}'"
  end
end
