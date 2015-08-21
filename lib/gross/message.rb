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
    #
    # A message that can be sent to a {Machine machine} in order to send it commands
    #
    class Message
        #
        # Constructs a {Message message} of type +type+, with arguments +**kwargs**+
        #
        # @note {#new} is a private method, and any {Message message} creation should happen using one of the Factory Methods
        #
        def initialize(type, **kwargs)
            @type = type
            @args = kwargs
        end
        private_class_method :new

        #
        # Returns the type of the message
        #
        # Possible values are:
        # [+:up+]   {Task} {#id} just finished upping
        # [+:down+] {Task} {#id} should be downed with all of its dependencies
        # [+:exit+] All tasks should be downed, and the {Machine machine} should be taken down
        #
        # @return [:up, :down, :exit] The type of the message
        #
        attr_reader :type

        #
        # Returns the +id+ of the message
        #
        # Well-defined if {#type} is either +:up+ or +:down+
        #
        # @return [Fixnum] The identifier that the message is dealing about
        #
        def id
            return @args[:id]
        end

        #
        # @!group Factory Methods
        #

        #
        # Creates a {Message message} reporting task +id+ just finished upping
        #
        # @return [Message] A message that states task +id+ is now up
        #
        def self.up(id)
            return new(:up, { id: id })
        end

        #
        # Creates a {Message message} reporting task +id+ is asking to be taken down, along with
        # all of its dependencies
        #
        # @return [Message] A message that states task +id+ should be taken down
        #
        def self.down(id)
            return new(:down, { id: id })
        end

        #
        # Creates a {Message message} stating the entire machine should be taken down and stopped
        #
        # @return [Message] A message that states the {Machine machine} should be taken down
        #
        def self.exit
            return new(:exit, {})
        end

        #
        # @!endgroup
        #
    end
end
