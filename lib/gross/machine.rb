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
    #
    # The machine that will run and backtrack the tasks.
    #
    # @example Simple Hello World machine
    #   g = Gross::Machine.new
    #   g.print 'Hello, World!'
    #   g.run
    #
    class Machine
        #
        # Initializes a machine with a given name
        #
        # @param name [String] The name of the machine, will be used in logs
        #
        def initialize(name = 'MAIN')
            @tasks = []
            @context = OpenStruct.new
            @queue = Queue.new
            @name = name
        end

        #
        # Returns the command queue to this {Machine machine}
        #
        # Any {Message message} can be sent to the current {Machine machine}.
        #
        # @return [Queue<Message>] The command queue that can be used to send {Message messages} to the machine
        # @see Message The documentation of Message, for a description of what can be sent on this queue
        #
        attr_reader :queue

        #
        # Adds a {Task task} to be run
        #
        # @param name [String] The name of the task, will be used in logs
        # @param up [#call] The function to call when the task should go up
        # @param down [#call] The function to call when the task should go down
        #
        # @return [Task] The task just added
        #
        def add_task(name: '', up: lambda {}, down: lambda {})
            id = @tasks.length
            Gross::log.debug (name ? "Adding task[#{@name}[#{id}]] #{name}" : "Adding unnamed task[#{@name}[#{id}]]")
            new_task = Task.new(id, name, @name, @queue, up, down)
            @tasks << new_task
            return new_task
        end

        #
        # Runs the machine, backtracking when needed
        #
        # @param extqueue [Queue<Message>] The queue that will be used to output messages reporting when all the states
        #   are up and when a state is going down, requiring possible backtracking of machines that depend on this one
        #
        # @return [void] Returns only when receives an exit message on its {#queue command queue}
        #
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
        #
        # Takes down task +id+, after all its dependencies have been (recursively) taken down
        #
        # @param id [Fixnum] The +id+ of the task to take down, as returned by {Task#id +task.id+}
        #
        # @return [void] Returns when task has been taken down
        #
        def down(id)
            Gross::log.info "Task[#{@name}[#{id}]] going down: #{@tasks[id].name}"
            @tasks[id].rdeps.each do |t|
                down t if @tasks[t].up?
            end
            @tasks[id].down
            Gross::log.info "Task[#{@name}[#{id}]] successfully backtracked: #{@tasks[id].name}"
        end


        #
        # Shortens message +msg+ if it is too long to properly fit a log line
        #
        # @param msg [String] The message to shorten
        #
        # @return [String] The message, clipped to a maximum of 50 characters
        #
        def shorten(msg)
            msg = msg.to_s
            if msg.length > 50
                return msg[0, 47] + '...'
            else
                return msg
            end
        end
    end
end

# Require task files
Dir[File.dirname(__FILE__) + '/tasks/*.rb'].each{ |file| require file }
