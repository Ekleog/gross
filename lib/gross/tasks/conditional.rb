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
        # Adds a conditional task
        #
        # A conditional task will evaluate a series of conditions, stopping at the first one which
        # evaluates to +true+ and executing the corresponding code
        #
        # The argument +args+ is defined as a list of (+name+, +condition+, +code+) triplets.
        # [+name+] +name+ is the human-readable name by which name the internally-generated
        #          {Machine machine} --- actual name will be current_task.hrid[name]. Should be set as a
        #          name clearly identifying the condition
        # [+condition+] +condition+ is the condition given as a {file:docs/ContextCallable.rdoc ContextCallable}
        # [+code+] +code+ is the code generator, given as a {file:docs/MachineCallable.rdoc MachineCallable}
        #
        # @param name [String] A human-readable name for the task
        # @param args [Array<Array<(String, #call, #call)>>] The elements to evaluate, see description above
        #
        # @return [Task] A task that implements the conditional behaviour defined above
        #
        def conditional(name='conditional', args)
            machine = nil
            queue = Queue.new
            thread = nil
            task = nil
            task = add_task(
                name: name,
                up:   lambda do
                    args.each do |name, cond, code|
                        if cond.call @context
                            machine = Machine.new "#{task.hrid}[#{name}]"
                            code.call machine
                            thread = Thread.new { machine.run queue }
                            while queue.pop != :up; end
                            break
                        end
                    end
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
