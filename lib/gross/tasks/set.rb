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
        # @!group Tasks
        #

        #
        # Sets a variable to a value
        #
        # @param variable [ContextCallable] Variable name, given as a {file:docs/ContextCallable.rdoc ContextCallable}
        # @param value [ContextCallable] Value of the variable, given as a {file:docs/ContextCallable.rdoc ContextCallable}
        #
        def set(variable, value='', &block)
            varname, var = context_callable variable
            valname, val = context_callable(value, &block)

            add_task(
                name: "set '#{varname}' := '#{valname}'",
                up: lambda { @context[var.call @context] = val.call @context },
                down: lambda { @context.delete_field var.call @context }
            )
        end
    end
end
