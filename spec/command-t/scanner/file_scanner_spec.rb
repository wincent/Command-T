# Copyright 2010-2013 Wincent Colaiuta. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'spec_helper'
require 'command-t/scanner/file_scanner'
require 'command-t/scanner/git_scanner'

module VIM; end

dir = File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures')
all_fixtures = %w(
  bar/abc bar/xyz baz bing foo/alpha/t1 foo/alpha/t2 foo/beta
)

shared_examples "file_scanners" do
  describe 'paths method' do
    it 'returns a list of regular files' do
      scanner.paths.should =~ all_fixtures
    end
  end

  describe 'flush method' do
    it 'forces a rescan on next call to paths method' do
      first = scanner.paths
      scanner.flush
      scanner.paths.object_id.should_not == first.object_id
    end
  end

  describe 'maxfiles option' do
    it 'returns fewer than maxfiles' do
      scanner.send(:initialize, dir, :max_files => 2)
      scanner.paths.should =~ %w(bar/abc bar/xyz)
    end
  end

  describe 'path= method' do
    it 'allows repeated applications of scanner at different paths' do
      scanner.paths.should =~ all_fixtures

      # drill down 1 level
      scanner.path = File.join(dir, 'foo')
      scanner.paths.should =~ %w(alpha/t1 alpha/t2 beta)

      # and another
      scanner.path = File.join(dir, 'foo', 'alpha')
      scanner.paths.should =~ %w(t1 t2)
    end
  end

  describe "'wildignore' exclusion" do
    it "calls on VIM's expand() function for pattern filtering" do
      scanner.send(:initialize, dir)
      mock(::VIM).evaluate(/expand\(.+\)/).times(7)
      scanner.paths
    end
  end
end

describe CommandT::RecursiveFileScanner do
  before do
    @scanner = CommandT::RecursiveFileScanner.new dir

    # scanner will call VIM's expand() function for exclusion filtering
    stub(::VIM).evaluate(/exists/) { 1 }
    stub(::VIM).evaluate(/expand\(.+\)/) { '0' }
    stub(::VIM).evaluate(/wildignore/) { '' }
  end

  include_examples "file_scanners" do
    def scanner
      @scanner
    end
  end

  describe ':max_depth option' do
    it 'does not descend below "max_depth" levels' do
      @scanner = CommandT::RecursiveFileScanner.new dir, :max_depth => 1
      @scanner.paths.should =~ %w(bar/abc bar/xyz baz bing foo/beta)
    end
  end
end

describe CommandT::GitScanner do
  before do
    @scanner = CommandT::GitScanner.new dir

    # scanner will call VIM's expand() function for exclusion filtering
    stub(::VIM).evaluate(/exists/) { 1 }
    stub(::VIM).evaluate(/expand\(.+\)/) { '0' }
    stub(::VIM).evaluate(/wildignore/) { '' }
  end

  include_examples "file_scanners" do
    def scanner
      @scanner
    end
  end
end
