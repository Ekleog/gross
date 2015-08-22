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
        # Adds a case task
        #
        # A case task will evaluate a value, and then execute the code corresponding to the computed value,
        # inside a dictionary -- defaulting to a default execution.
        #
        # @param value [ContextCallable] is the value, given as a {file:docs/ContextCallable.rdoc ContextCallable}
        # @param dict [Hash<Object, MachineCallable>] is the dictionary, with as keys the possible values.
        #   If +value+ is a key in this array, then the correspondingg value will be evaluated as a
        #   {file:docs/MachineCallable.rdoc MachineCallable}
        # @param default [MachineCallable] A machine callable to call in case no key matches
        # @param name [String] A human-readable name for the task
        #
        # @return [Task] A task that implements the case behaviour defined above
        #
        def case(value, dict, default = ->(h) {}, name='conditional')
            machine = nil
            queue = Queue.new
            thread = nil
            task = nil
            task = add_task(
                name: name,
                up:   lambda do
                    machine = Machine.new "#{task.hrid}[#{name}]", @context
                    v = value.call @context
                    if dict.has_key? v
                        dict[v].call machine
                    else
                        default.call machine
                    end
                    thread = Thread.new { machine.run queue }
                    while queue.pop != :up; end
                end,
                down: lambda do
                    machine.queue << Message.exit
                    thread.join
                end
            )
        end

        #
        # @!endgroup
        #
    end
end
