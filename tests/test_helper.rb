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
require 'thread'

module Gross
    @@log = Logger.new STDERR
end

def short(msg)
    if msg.length > 7
        return msg[0, 10] + '...'
    else
        return msg
    end
end

def run_block_until_up(g)
    queue = Queue.new
    thr = Thread.new { g.run queue }
    # Wait until machine is up
    while queue.pop.type != :up; end
    return queue
end

def down_block_until_down(g, q, id)
    g.queue << Gross::Message.down(id)
    # Wait until down
    while q.pop.type != :down; end
end
