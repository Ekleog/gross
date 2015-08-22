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

class TestTaskCase < MiniTest::Test
    def do_test(name, value, out)
        g = Gross::Machine.new "TestTaskCase::#{name}"
        blk = g.blocker
        var = g.set('var', value) << blk
        g.case(->(c) { c.var * 6 }, {
        42 => lambda do |h|
            h.print 'Wonderful'
            h.rprint 'Wonderful'
        end,
        1337 => lambda do |h|
            h.print 'DOESN\'T WORK'
            h.rprint 'DOESN\'T WORK'
        end
        }, lambda do |h|
            h.print 'WORKS'
            h.rprint 'WORKS'
        end) << var
        q = nil
        assert_output(out, '') { q = run_block_until_up g }
        assert_output(out, '') { down_block_until_down(g, q, blk.id) }
        g.queue << Gross::Message.exit
    end

    def test_in_it
        do_test 'test_in_it', 7, 'Wonderful'
    end

    def test_not_in_it
        do_test 'test_not_in_it', 9, 'WORKS'
    end
end
