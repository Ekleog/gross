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

module Gross
private
    class Message
        private_class_method :new
        def initialize(type, **kwargs)
            @type = type
            @args = kwargs
        end

        attr_reader :type

        def id
            return @args[:id]
        end

        def self.up(id)
            return new(:up, { id: id })
        end

        def self.down(id)
            return new(:down, { id: id })
        end

        def self.exit
            return new(:exit, {})
        end
    end
end
