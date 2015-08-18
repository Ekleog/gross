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
        def set(variable, value)
            var = variable
            var = ->(ctx) { variable } if !var.respond_to? :call
            val = value
            val = ->(ctx) { value } if !val.respond_to? :call
            add_task(
                name: "set '#{shorten var.call no_context}' := '#{shorten val.call no_context}'",
                up: lambda { @context[var.call @context] = val.call @context },
                down: lambda { @context.delete_field var.call no_context }
            )
        end
    end
end
