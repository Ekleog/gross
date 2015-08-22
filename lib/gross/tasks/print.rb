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

module Gross
    class Machine
        #
        # @!group Tasks::Debug
        #

        #
        # Writes a message to stdout when task is brought up
        #
        # @overload print(message)
        #   @param message [ContextCallable] Message to print as a {file:docs/ContextCallable.rdoc ContextCallable}
        # @overload print(&block)
        #   @param block [#call] Message to print as a {file:docs/ContextCallable.rdoc ContextCallable}
        #
        # @return [Task] A task that prints the message given as a parameter when being brought up
        #
        def print(message='', &block)
            name, msg = context_callable(message, &block)
            add_task(
                name: "print '#{name}'",
                instant: true,
                up: lambda { $stdout.print(msg.call @context) }
            )
        end

        #
        # @!endgroup
        #
    end
end
