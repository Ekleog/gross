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

require 'test_helper'

class TestTaskSet < MiniTest::Test
    def test_basic
        g = Gross::Machine.new
        blk = g.blocker
        var = g.set('var', 'test') << blk
        g.print{|c| "This is a #{c.var} upping"} << var
        g.rprint{|c| "This is a #{c.var} downing"} << var
        assert_output('This is a test upping', '') { g.run }
        assert_output('This is a test downing', '') { g.down(blk.id) }
    end
end
