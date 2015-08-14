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

require 'gross/task'

module Gross
    class Machine
        def initialize()
            @tasks = []
        end

        def add_task(up: lambda {}, down: lambda {})
            new_task = Task.new(@tasks.length, up, down)
            @tasks << new_task
            return new_task
        end

        def run()
            @tasks.each do |t|
                t.up()
            end
        end

        def down(id)
            tasks = [id]
            while !tasks.empty? do
                next_tasks = []
                tasks.each do |t|
                    if @tasks[t].up?
                        next_tasks += @tasks[t].rdeps
                        @tasks[t].down
                    end
                end
                tasks = next_tasks
            end
        end

        def println(msg)
            add_task(up: lambda { puts msg }, down: lambda {})
        end

        def rprintln(msg)
            add_task(up: lambda {}, down: lambda { puts msg })
        end

        def blocker()
            add_task(up: lambda {}, down: lambda {})
        end

        def die()
            add_task(up: lambda { raise 'dying' }, down: lambda {})
        end
    end
end
