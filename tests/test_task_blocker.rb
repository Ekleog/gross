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

require 'gross'
require 'minitest/spec'
require 'minitest/autorun'

class TestTaskBlocker < MiniTest::Test
    def test_basic
        g = Gross::Machine.new
        blk = g.blocker
        pr = g.println("UP") << blk;
        rpr = g.rprintln("DOWN") << pr;
        rpr2 = g.rprintln("DOWN2") << pr;
        rpr3 = g.rprintln("DOWN3") << rpr << rpr2;
        rpr4 = g.rprintln("DOWN4");
        assert_output("UP\n", '') { g.run }
        assert_output("DOWN\nDOWN2\nDOWN3\n", '') { g.down(blk.id) }
    end
end
