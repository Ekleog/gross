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
private
    class Task
        def initialize(id, ident, name, machine_name, queue, up, down)
            @id = id        # Task ID
            @ident = ident  # Human-readable ID (short)
            @name = name    # Human-readable task name
            @machine_name = machine_name # Machine name
            @queue = queue  # Pointer to the event queue in the Gross::Machine
            @status = :down # Status, among :down, :upping, :up and :downing
            @up = up        # Up function
            @down = down    # Down function
            @deps = []      # List of task IDs this task depends on
            @rdeps = []     # List of task IDs that depend on this task
            @thread = nil   # Thread running, if :upping or :downing ; nil otherwise
        end

        attr_reader :id, :name, :deps, :rdeps

        def up?
            return @status == :up
        end

        def upped?
            return @status == :upping || @status == :up
        end

        def up
            Gross::log.info "  #{@name}: UPPING[#{hrid}]"
            @status = :upping
            @thread = Thread.new do
                begin
                    @up.call
                    @status = :up
                    Gross::log.info "  #{@name}: UP[#{hrid}]"
                    @queue << Message.up(@id)
                rescue
                    # Logger is thread-safe
                    Gross::log.error "Error while upping[#{hrid}] #{@name}: #{e}"
                end
            end
        end

        def down
            Gross::log.info "  #{@name}: DOWNING[#{hrid}]"
            @status = :downing
            begin
                @down.call
            rescue => e
                Gross::log.warn "Error while downing[#{hrid}] #{@name}: #{e}"
            end
            @status = :down
            Gross::log.info "  #{@name}: DOWN[#{hrid}]"
        end

        def <<(task)
            @deps << task.id
            task.append_to_rdeps @id
            return self
        end

        def &(task)
            return self << task
        end

    protected
        def append_to_rdeps(id)
            @rdeps << id
        end

    private
        # Human-readable identifier
        def hrid
            return "#{@ident}(#{@machine_name}[#{@id}])"
        end

    end
end
