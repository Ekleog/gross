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
            ['default', lambda { |c| true }, lambda do |h|
                h.print 'DOESN\'T WORK'
                h.rprint 'DOESN\'T WORK'
            end]
        ]) << var
        q = nil
        assert_output('WORKS', '') { q = run_block_until_up g }
        assert_output('WORKS', '') { down_block_until_down(g, q, blk.id) }
        g.queue << Gross::Message.exit
    end

    def test_second
        g = Gross::Machine.new 'TestTaskConditional::test_second'
        blk = g.blocker
        var = g.set('cond', true) << blk
        g.conditional([
            ['false', lambda { |c| false }, lambda do |h|
                h.print 'FAILS' # Yes, I really have no clue what to put there, so let's be more diverse
                h.rprint 'FAILS'
            end],
            ['true', lambda { |c| c.cond }, lambda do |h|
                h.print 'YES'
                h.rprint 'YEEESS'
            end],
            ['default', lambda { |c| true }, lambda do |h|
                h.print 'WHY?'
            end]
        ]) << var
        q = nil
        assert_output('YES', '') { q = run_block_until_up g }
        assert_output('YEEESS', '') { down_block_until_down(g, q, blk.id) }
        g.queue << Gross::Message.exit
    end

    def test_last
        g = Gross::Machine.new 'TestTaskConditional::test_last'
        blk = g.blocker
        var = g.set('cond', false) << blk
        g.conditional([
            ['false', lambda { |c| false }, lambda do |h|
                h.print 'FAILS'
                h.rprint 'FAILS'
            end],
            ['other_false', lambda { |c| c.cond }, lambda do |h|
                h.print 'NOTHING'
                h.rprint 'NOTHING MORE'
            end],
            ['default', lambda { |c| true }, lambda do |h|
                h.print 'DID IT'
                h.rprint 'WELL DONE'
            end]
        ]) << var
        q = nil
        assert_output('DID IT', '') { q = run_block_until_up g }
        assert_output('WELL DONE', '') { down_block_until_down(g, q, blk.id) }
        g.queue << Gross::Message.exit
    end
end
