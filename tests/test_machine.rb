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

class TestMachine < MiniTest::Test
    def do_assert(g, blk, msg)
        assert_output('', '') { g.run }
        assert_output(msg, '') { g.down(blk.id) }
    end

    def test_basic
        g = Gross::Machine.new
        blk = g.blocker
        g.rprint('DOWN') << blk
        do_assert g, blk, 'DOWN'
    end

    def test_diamond
        g = Gross::Machine.new
        blk = g.blocker
        d1 = g.rprint('1') << blk
        d2 = g.rprint('2') << blk
        g.rprint('3') << d1 & d2
        do_assert g, blk, '123'
    end

    def test_redundent
        g = Gross::Machine.new
        blk = g.blocker
        g.rprint('DOWN') << blk & blk & blk
        do_assert g, blk, 'DOWN'
    end
end
