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
    def do_test(name, var, val) # var must be equivalent to "var"
        g = Gross::Machine.new "TestTaskSet::#{name}"
        blk = g.blocker
        var = g.set(var, val) << blk
        g.print{|c| "This is a #{c.var} upping"} << var
        g.rprint{|c| "This is a #{c.var} downing"} << var
        q = nil
        assert_output("This is a #{val} upping", '') { q = run_block_until_up g }
        assert_output("This is a #{val} downing", '') { down_block_until_down(g, q, blk.id) }
        g.queue << Gross::Message.exit
    end

    def test_basic
        do_test 'test_basic', 'var', 'test'
    end

    def test_val_not_string
        do_test 'test_val_not_string::true', 'var', true
        do_test 'test_val_not_string::42', 'var', 42
        do_test 'test_val_not_string::nil', 'var', nil
    end

    def test_var_not_string
        do_test 'test_var_not_string', :var, 'test'
    end
end
