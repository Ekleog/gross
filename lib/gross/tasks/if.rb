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

require 'gross/tasks/conditional'

module Gross
    class Machine
        def if(name='if', cond, &code)
            @current_if = [[name, cond, code]]
        end

        def elsif(name='elsif', cond, &code)
            @current_if << [name, cond, code]
        end

        def else(name='else', &code)
            @current_if << [name, lambda { |c| true }, code]
        end

        def end(name='conditional')
            args = @current_if
            @current_if = nil
            return conditional(name, args)
        end
    end
end
