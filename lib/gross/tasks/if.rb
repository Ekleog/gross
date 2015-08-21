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

require 'gross/tasks/conditional'

module Gross
    class Machine
        #
        # @!group Tasks::IfElse
        #

        #
        # Prepares a conditional task with its first element
        #
        # @param name [String] The human-readable name for the condition
        # @param cond [#call]  The condition as a {file:docs/ContextCallable.rdoc ContextCallable}
        # @param code [#call]  The code as a {file:docs/MachineCallable.rdoc MachineCallable}
        #
        # @return [void] Returns nothing, just prepares a {#conditional conditional} task
        #
        def if(name='if', cond, &code)
            @current_if = [[name, cond, code]]
        end

        #
        # Prepares a conditional task by adding it some elements
        #
        # @param (see #if)
        # @return (see #if)
        #
        def elsif(name='elsif', cond, &code)
            @current_if << [name, cond, code]
        end

        #
        # Prepares a conditional task by adding it a catch-all element
        #
        # @param name (see #if)
        # @param code (see #if)
        # @return (see #if)
        #
        def else(name='else', &code)
            @current_if << [name, lambda { |c| true }, code]
        end

        #
        # Completes conditional task just built, returning the generated {Task task}
        #
        # @param name [String] A name for the entire generated +if+/+then+/+else+ conditional
        #
        # @return [Task] A {#conditional} task that implements the behaviour requested by previous
        #   {#if}/{#elsif}/{#else} method calls
        #
        def end(name='conditional')
            args = @current_if
            @current_if = nil
            return conditional(name, args)
        end

        #
        # @!endgroup
        #
    end
end
