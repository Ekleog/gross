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
        # Format for args:
        # [
        #   [name, cond, code],
        #   [name, cond, code],
        #   ...,
        #   [name, cond, code]
        # ]
        # First match will stop evaluation
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
                            machine = Machine.new "#{task.hrid}[#{name}"
                            code.call machine
                            thread = Thread.new { machine.run queue }
                            while queue.pop.type != :up; end
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
    end
end
