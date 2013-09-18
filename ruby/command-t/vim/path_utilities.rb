# Copyright 2010-2011 Wincent Colaiuta. All rights reserved.
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

require 'command-t/vim'

module CommandT
  module VIM
    module PathUtilities

    private

      def get_string name
        VIM::exists?(name) ? ::VIM::evaluate("#{name}").to_s : nil
      end

      def relative_path_under_working_directory path
        # any path under the working directory will be specified as a relative
        # path to improve the readability of the buffer list etc
        pwd = File.expand_path(VIM::pwd) + '/'
        path.index(pwd) == 0 ? path[pwd.length..-1] : path
      end

      def nearest_scm_directory
        # find nearest parent determined to be an scm root
        # based on marker directories in default_markers or
        # g:command_t_root_markers

        markers = get_string('g:command_t_root_markers')
        default_markers = ['.git', '.hg', '.svn', '.bzr', '_darcs']
        if not (markers and markers.length)
            markers = default_markers
        end

        path = File.expand_path(VIM::current_file_dir)
        while !markers.
            map{|dir| File.join(path, dir)}.
            map{|dir| File.directory?(dir)}.
            any?
          return Dir.pwd if path == "/"
          path = File.expand_path(File.join(path, '..'))
        end
        path
      end

    end # module PathUtilities
  end # module VIM
end # module CommandT
