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
require 'gross/message'

module Gross
    #
    # A task that can be ran by a {Machine machine}, and be backtracked or ask for backtracking
    #
    class Task
        #
        # Constructs a {Task task}
        #
        # @param id             [Fixnum]            The task identifier, see also {#id}
        # @param name           [String]            An human-readable task name, used for logging purposes
        # @param machine        [Machine]           The parent machine
        #   {Machine machine} to which this {Task task} is attached
        # @param instant        [Boolean]           If true, then it is assumed the up and down function are
        #   instantaneous, and they will not be run in another thread
        # @param up             [#call]             A function to call so as to up the task
        # @param down           [#call]             A function to call so as to take the task down
        #
        def initialize(id, name, machine, instant, up, down)
            @id = id
            @name = name
            @machine = machine
            @status = :down # Status, among :down, :upping, :up and :downing
            @instant = instant
            @up = up
            @down = down
            @deps = []
            @rdeps = []
            @thread = nil   # Thread running, if :upping or :downing ; nil otherwise
        end

        #
        # Returns the task identifier
        #
        # This task identifier can be used to uniquely identify a {Task task} inside a {Machine machine}
        #
        # @return [Fixnum] The task identifier of this task
        #
        attr_reader :id

        #
        # Returns the human-readable task name
        #
        # @return [String] A human-readable task name
        #
        attr_reader :name

        #
        # Returns the list of task identifiers that this task depends upon
        #
        # @return [Array<Fixnum>] A list of all the task IDs this tasks depends on
        #
        attr_reader :deps

        #
        # Returns a list of all the task identifiers that depend upon this task
        #
        # @return [Array<Fixnum>] A list of all the task IDs that depend on this task
        #
        attr_reader :rdeps

        #
        # Returns a human-readable identifier that can be used for logging purposes
        #
        # It is composed like this: machine_name[task_id]
        #
        # @return [String] A human-readable identifier
        #
        def hrid
            return "#{@machine.name}[#{@id}]"
        end

        #
        # Is the task currently up?
        #
        # @return [Boolean] Whether the task is currently up
        #
        def up?
            return @status == :up
        end

        #
        # Has the task been upped?
        #
        # Returns +true+ if the task is currently up, or has started to be taken up
        #
        # @return [Boolean] Whether the task has been upped
        #
        def upped?
            return @status == :upping || @status == :up
        end

        #
        # Take the task up
        #
        # Start the task in a new subprocess, then report completion as soon as task is up
        #
        # @return [void] Returns immediately, completion being notified through the +queue+ parameter to {#initialize}
        #
        def up
            Gross::log.info "  UPPING[#{hrid}]: #{@name}"
            @status = :upping
            if @instant
                instant_up
            else
                @thread = Thread.new { instant_up }
            end
        end

        #
        # Take the task down
        #
        # @return [void] Returns as soon as task has been taken down
        #
        def down
            Gross::log.info "  DOWNING[#{hrid}]: #{@name}"
            @status = :downing
            begin
                @down.call
            rescue => e
                Gross::log.warn "Error while downing[#{hrid}] #{@name}: #{e}"
            end
            @status = :down
            Gross::log.info "  DOWN[#{hrid}]: #{@name}"
        end

        #
        # Make this task depend on other task +task+
        #
        # This {Task task} will be brought up only after task +task+ is up, and as soon as task +task+
        # will notify it is going down, this task will go down too.
        #
        # @param task [Task] The task this task is to depend on
        #
        # @return [self]
        #
        # @example Depend on multiple tasks
        #   my_task << dependency_1 & dependency_2 & dependency_3
        #
        def depends(task)
            @deps << task.id
            task.append_to_rdeps @id
            return self
        end
        alias_method :<<, :depends
        alias_method :&, :depends

    protected
        #
        # Helper method made for adding task id +id+ to +@rdeps+
        #
        # @param id [Fixnum] The id of the task that depends on +self+
        #
        def append_to_rdeps(id)
            @rdeps << id
        end

    private

        #
        # Take the task up, instantly
        #
        def instant_up
            begin
                @up.call
                @status = :up
                Gross::log.info "  UP[#{hrid}]: #{@name}"
                @machine.queue << Message.up(@id)
            rescue => e
                # Logger is thread-safe
                Gross::log.error "Error while upping[#{hrid}] #{@name}: #{e}"
            end
        end
    end
end
