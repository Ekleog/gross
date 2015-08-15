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
private
    class Task
        def initialize(id, up, down)
            @id = id        # Task ID
            @status = :down # Status, among :down, :upping, :up and :downing
            @up = up        # Up function
            @down = down    # Down function
            @rdeps = []     # List of task IDs that depend on this task
        end

        attr_reader :id, :rdeps

        def up?()
            return @status == :up
        end

        def up()
            @status = :upping
            @up.call
            @status = :up
        end

        def down()
            @status = :downing
            @down.call rescue
            @status = :down
        end

        def <<(task)
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
    end
end
