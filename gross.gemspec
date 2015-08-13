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

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
    spec.name          = 'gross'
    spec.version       = '0.1'
    spec.date          = DateTime.now.strftime '%F'
    spec.summary       = %q{A DSL for backtracking-based programs and network configuration}
    spec.description   = File.read('README.rdoc')
    spec.authors       = ['Leo Gaspard']
    spec.email         = 'leo@gaspard.io'
    spec.files         = Dir['lib/gross{,/*}.rb']
    spec.test_files    = Dir['tests/test_*']
    spec.homepage      = 'https://github.com/Ekleog/gross'
    spec.license       = 'GPLv3'
end
