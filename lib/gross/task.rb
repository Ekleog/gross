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
            @id = id
            @is_up = false
            @up = up
            @down = down
            @rdeps = []
        end

        attr_reader :id, :rdeps

        def up?()
            return @is_up
        end

        def up()
            @up.call
            @is_up = true
        end

        def down()
            @is_up = false
            @down.call
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
