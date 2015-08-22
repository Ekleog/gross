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

class TestTaskBlocker < MiniTest::Test
    def test_loop
        g = Gross::Machine.new "TestTaskBlocker::test_loop"
        blk = g.blocker
        var = g.set :var, 0
        prt = g.print(->(c) { c.var }) << blk & var
        g.if ->(c) { c.var < 9 } do |h|
            nv = h.set :var, ->(c) { c.var + 1 }
            blk.downup(h) << nv
        end
        g.end << prt
        q = nil
        assert_output('0123456789', '') { q = run_block_until_up g }
        assert_output('', '') { down_block_until_down(g, q, blk.id) }
        g.queue << Gross::Message.exit
    end
end
