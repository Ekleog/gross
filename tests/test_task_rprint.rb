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

class TestTaskRprint < MiniTest::Test
    def do_test(msg)
        g = Gross::Machine.new "TestTaskRprint[#{short msg}]"
        rpr = g.rprint(msg)
        q = nil
        assert_output('', '') { q = run_block_until_up g }
        assert_output(msg, '') { down_block_until_down(g, q, rpr.id) }
        g.queue << Gross::Message.exit
    end

    def test_basic
        do_test 'Hello World!'
        do_test 'Goodbye everyone...'
    end

    def test_empty
        do_test ''
    end

    def test_long
        do_test 'A' * 10000
    end
end
