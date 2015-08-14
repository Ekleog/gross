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
    def do_assert(g, blk, msg)
        assert_output('', '') { g.run }
        assert_output(msg, '') { g.down(blk.id) }
    end

    def test_basic
        g = Gross::Machine.new
        blk = g.blocker
        g.rprintln('DOWN') << blk
        do_assert g, blk, "DOWN\n"
    end

    def test_diamond
        g = Gross::Machine.new
        blk = g.blocker
        d1 = g.rprintln('DOWN 1') << blk
        d2 = g.rprintln('DOWN 2') << blk
        g.rprintln('DOWN 3') << d1 << d2
        do_assert g, blk, "DOWN 1\nDOWN 2\nDOWN 3\n"
    end
end
