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
        # @param context [OpenStruct] The variables that should be available
        #
        def initialize(name = 'MAIN', context = OpenStruct.new)
            @tasks = []
            @context = context
            @queue = Queue.new
            @name = name
        end

        #
        # Returns the name of this machine
        #
        # This name should only be used for logging purposes, it is not at all supposed to be unique
        #
        # @return [String] The name of this machine
        #
        attr_reader :name

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
        # @param block [#call] A function that takes a task ID, machine name and command queue as
        # parameters, and returns the task to be added
        #
        # @return [Task] The task just added
        #
        def add_custom_task(block)
            new_task = block.call @tasks.length, self
            Gross::log.debug "Adding task[#{new_task.hrid}]: #{new_task.name}"
            @tasks << new_task
            return new_task
        end

        #
        # Adds a {Task task} to be run
        #
        # @param name [String] The name of the task, will be used in logs
        # @param up [#call] The function to call when the task should go up
        # @param down [#call] The function to call when the task should go down
        #
        # @return [Task] The task just added
        #
        def add_task(name: '', up: lambda {}, down: lambda {}, instant: false)
            add_custom_task (lambda do |id, machine|
                return Task.new(id, name, machine, instant, up, down)
            end)
        end

        #
        # Runs the machine, backtracking when needed
        #
        # @param extqueue [Queue<:up, :down, :down_done>] The queue that will be used to output messages reporting when all the states
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
                if @queue.empty? && @tasks.all? { |t| t.up? }
                    Gross::log.info "All tasks up for machine '#{@name}'"
                    extqueue << :up unless extqueue == nil
                end
                msg = @queue.pop
                case msg.type
                when :up
                    up msg.id, extqueue
                when :down
                    if @tasks.all? { |t| t.up? }
                        Gross::log.info "Some tasks down for machine '#{@name}'"
                        extqueue << :down unless extqueue == nil
                    end
                    down msg.id, extqueue
                    extqueue << :down_done
                when :downup
                    Gross::log.debug "Starting DOWNUP on '#{@name}'"
                    if @tasks.all? { |t| t.up? }
                        Gross::log.info "Some tasks down for machine '#{@name}'"
                        extqueue << :down unless extqueue == nil
                    end
                    down msg.id, extqueue
                    Gross::log.debug "DOWN done, UP starting on '#{@name}'"
                    @tasks[msg.id].up
                    Gross::log.debug "Ending DOWNUP on '#{@name}'"
                when :exit
                    @tasks.each_index { |id| down id, extqueue if @tasks[id].upped? }
                    Gross::log.info "Machine '#{@name}' exited"
                    return
                else
                    Gross::log.error "Machine '#{@name}' received invalid message: #{msg}"
                end
            end
        end

    private
        #
        # Starts up all reverse dependencies of task +id+ that coule be started up,
        # assuming task +id+ has just been started up
        #
        # @param id [Fixnum] The +id+ of the task whose rdeps should be upped, as returned by {Task#id +task.id+}
        #
        # @return [void]
        #
        def up(id, extqueue)
            @tasks[id].rdeps.each do |rdep|
                if @tasks[rdep].deps.all? { |dep| @tasks[dep].up? }
                    @tasks[rdep].up unless @tasks[rdep].upped?
                end
            end
        end

        #
        # Takes down task +id+, after all its dependencies have been (recursively) taken down
        #
        # @param id [Fixnum] The +id+ of the task to take down, as returned by {Task#id +task.id+}
        #
        # @return [void] Returns when task has been taken down
        #
        def down(id, extqueue)
            Gross::log.info "Task[#{@name}[#{id}]] going down: #{@tasks[id].name}"
            @tasks[id].rdeps.each do |t|
                down t, extqueue if @tasks[t].up?
            end
            @tasks[id].down
            Gross::log.info "Task[#{@name}[#{id}]] successfully backtracked: #{@tasks[id].name}"
        end

        #
        # Returns a lambda taking a context and returning a value out of an (argument, block) pair
        #
        # @param argument [ContextCallable] A {file:docs/ContextCallable.rdoc ContextCallable}, or
        # @param block [#call] A lambda that takes a context and returns a value
        #
        # @return [Array<(String, #call)>] A pair of a name and a lambda that takes a context and returns a value
        #
        def context_callable(argument, &block)
            name = '{{ function }}'
            arg = argument
            if !arg.respond_to? :call
                name = shorten arg
                arg = ->(ctx) { argument }
            end
            arg = block if block
            callback = lambda do |c|
                Gross::log.debug "    Calling ContextCallable with context: #{c}"
                arg.call c
            end
            return [name, callback]
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
