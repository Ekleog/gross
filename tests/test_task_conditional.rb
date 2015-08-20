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

class TestTaskConditional < MiniTest::Test
    def test_true
        g = Gross::Machine.new 'TestTaskConditional::test_basic'
        blk = g.blocker
        var = g.set('cond', true) << blk
        g.conditional([
            ['true', lambda { |c| c.cond }, lambda do |h|
                h.print 'WORKS'
                h.rprint 'WORKS'
            end],
            ['default', lambda { true }, lambda do |h|
                h.print 'DOESN\'T WORK'
                h.rprint 'DOESN\'T WORK'
            end]
        ]) << var
        q = nil
        assert_output('WORKS', '') { q = run_block_until_up g }
        assert_output('WORKS', '') { down_block_until_down(g, q, blk.id) }
        g.queue << Gross::Message.exit
    end
end
