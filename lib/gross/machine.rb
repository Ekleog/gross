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

require 'thread'
require 'gross/task'

module Gross
    class Machine
        def initialize
            @tasks = []
            @queue = Queue.new
        end

        def add_task(up: lambda {}, down: lambda {}, name: '')
            id = @tasks.length
            Gross::log.debug (name ? "Adding task[#{id}] #{name}" : "Adding unnamed task[#{id}]")
            new_task = Task.new(id, name, @queue, up, down)
            @tasks << new_task
            return new_task
        end

        def run
            Gross::log.info 'Starting'
            @tasks.each do |t|
                t.up if @tasks[t.id].deps.empty?
            end
            while !@tasks.all? { |t| t.up? }
                new_up = @queue.pop
                @tasks[new_up].rdeps.each do |rdep|
                    if @tasks[rdep].deps.all? { |dep| @tasks[dep].up? }
                        @tasks[rdep].up unless @tasks[rdep].upped?
                    end
                end
            end
            Gross::log.info 'All tasks up'
        end

        def down(id)
            Gross::log.info "Task[#{id}] going down: #{@tasks[id].name}"
            @tasks[id].rdeps.each do |t|
                down t if @tasks[t].up?
            end
            @tasks[id].down
            Gross::log.info "Task[#{id}] successfully backtracked: #{@tasks[id].name}"
        end

        def print(msg)
            add_task(up: lambda { $stdout.print msg }, down: lambda {}, name: "print '#{shorten msg}'")
        end

        def rprint(msg)
            add_task(up: lambda {}, down: lambda { $stdout.print msg }, name: "rprint '#{shorten msg}'")
        end

        def blocker
            add_task(up: lambda {}, down: lambda {}, name: 'blocker')
        end

    private
        def shorten(msg)
            if msg.length > 50
                return msg[0, 50] + '...'
            else
                return msg
            end
        end
    end
end
