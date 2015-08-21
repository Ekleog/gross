# This file is part of gross.
# Copyright (C) 2015 Leo Gaspard
#
# gross is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# gross is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gross.  If not, see <http://www.gnu.org/licenses/>.

require 'logger'

module Gross
    #
    # Returns the version of gross
    #
    # The version X.Y.Z will be bumped as follows:
    # [X, the major version] Will be bumped after a non-backwards-compatible change
    # [Y, the minor version] Will be bumped after backwards-compatible API changes
    # [Z, the patch version] Will be bumped after each patch that does not change API
    #
    # @return [String] The version of gross
    #
    VERSION = '0.0.1'

    #
    # Returns the logger to be used by gross {Machine machines}.
    #
    # Should provide at least {Logger#debug #debug}, {Logger#info #info}, {Logger#warn #warn},
    # {Logger#error #error} and {Logger#fatal #fatal}.
    #
    # @return [Logger] the logger gross will use to describe its evolution
    #
    @@log = Logger.new STDOUT
    @@log.progname = 'gross'
    def self.log; @@log; end
    def self.log=(log); @@log = log; end
end

require 'gross/task'
require 'gross/machine'
