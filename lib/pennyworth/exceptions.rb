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

module Pennyworth
  class WrongPasswordException < StandardError; end
  class SshKeysAlreadyExistsException < StandardError; end
  class SshConnectionFailed < StandardError; end
  class CommandNotFoundError < StandardError; end
  class BuildFailed < StandardError; end
  class InvalidHostError < StandardError; end
  class HostFileError < StandardError; end
  class LockError < StandardError; end

  class ExecutionFailed < StandardError
    def initialize(e)
      @message = e.message
      @message += "\nStandard output:\n #{e.stdout}\n"
      @message += "\nError output:\n #{e.stderr}\n"
    end

    def to_s
      @message
    end
  end
end