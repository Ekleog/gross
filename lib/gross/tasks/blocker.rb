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
    class BlockerTask < Task
        def initialize(id, name, machine)
            super(id, name, machine, true, lambda {}, lambda {})
        end

        def set_down(machine=@machine)
            return machine.add_task(
                name: "#{@name} downer",
                up:   lambda { @machine.queue << Message.down(@id) }
            )
        end

        def set_up(machine=@machine)
            return machine.add_task(
                name: "#{@name} upper",
                up:   lambda { @machine.queue << Message.up(@id) }
            )
        end

        def downup(machine=@machine)
            return machine.add_task(
                name: "#{@name} downupper",
                up: lambda { @machine.queue << Message.downup(@id) }
            )
        end
    end
    private_constant :BlockerTask

    class Machine
        #
        # @!group Tasks
        #

        #
        # Adds a blocker task
        #
        # A blocker is a dummy task, whose only aim is to provide a backtrack point
        #
        # @param name [String] A human-readable name for the task
        #
        # @return [Task] The created blocker task
        #
        def blocker(name='blocker')
            add_custom_task (lambda do |id, machine|
                return BlockerTask.new(id, name, machine)
            end)
        end

        #
        # @!endgroup
        #
    end
end
