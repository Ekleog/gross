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

require 'ostruct'
require 'gross/task'

module Gross
    class Machine
        def initialize(name = 'MAIN')
            @tasks = []
            @context = OpenStruct.new
            @queue = Queue.new
            @name = name
        end

        attr_reader :queue

        def add_task(ident: '', name: '', up: lambda {}, down: lambda {})
            id = @tasks.length
            Gross::log.debug (name ? "Adding task[#{@name}[#{id}]] #{name}" : "Adding unnamed task[#{@name}[#{id}]]")
            new_task = Task.new(id, ident, name, @name, @queue, up, down)
            @tasks << new_task
            return new_task
        end

        def run(extqueue = nil)
            Gross::log.info "Starting up machine '#{@name}'"
            @tasks.each do |t|
                t.up if @tasks[t.id].deps.empty?
            end
            while true
                msg = @queue.pop
                case msg.type
                when :up
                    @tasks[msg.id].rdeps.each do |rdep|
                        if @tasks[rdep].deps.all? { |dep| @tasks[dep].up? }
                            @tasks[rdep].up unless @tasks[rdep].upped?
                        end
                    end
                    if @tasks.all? { |t| t.up? }
                        Gross::log.info "All tasks up for machine '#{@name}'"
                        extqueue << Message.up(0) unless extqueue == nil
                    end
                when :down
                    down msg.id
                    extqueue << Message.down(0) unless extqueue == nil
                when :exit
                    @tasks.each_index { |id| down id if @tasks[id].upped? }
                    return
                else
                    Gross::log.error "Machine '#{@name}' received invalid message: #{msg}"
                end
            end
        end

    private
        def down(id)
            Gross::log.info "Task[#{@name}[#{id}]] going down: #{@tasks[id].name}"
            @tasks[id].rdeps.each do |t|
                down t if @tasks[t].up?
            end
            @tasks[id].down
            Gross::log.info "Task[#{@name}[#{id}]] successfully backtracked: #{@tasks[id].name}"
        end

        def shorten(msg)
            if msg.length > 50
                return msg[0, 50] + '...'
            else
                return msg
            end
        end

        def no_context
            return DummyContext.new
        end
    end

    class DummyContext < OpenStruct
        def method_missing(mid, *args)
            @table[mid] = "{{ #{mid} }}" if args.length == 0 && !@table.has_key?(mid)
            return super(mid, *args)
        end
    end
end

# Require task files
Dir[File.dirname(__FILE__) + '/tasks/*.rb'].each{ |file| require file }
