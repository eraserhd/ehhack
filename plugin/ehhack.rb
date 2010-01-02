# EhHack
#
# Copyright (C) 2009 Jason Felice <jason.m.felice@gmail.com>
#
# http://eraserhead.net/
#
# Vim plugin to make writing throw-away programs super quick.  This is
# distributed under the GPLv3.
#

require File.dirname(__FILE__)+"/ehhack/lang.rb"

module EhHack

  # I provide injectable access to the current Vim state.
  # 
  # Code outside of the top-level EhHack class methods do not access VIM::
  # directly; instead, a VimContext is used so that we can verify operation
  # under test.
  class VimContext
    attr_reader :buffer, :window

    def initialize(buffer = nil, window = nil)
      @buffer = buffer || VIM::Buffer.current
      @window = window || VIM::Window.current
    end

    def command(c)
      VIM::command(c)
    end

    def current_line
      buffer[window.cursor[0]]
    end

    def replace_buffer_with_template(template)
      i = 0
      template.split(/\r?\n/).each do |line|
        buffer.append(i, line)
        i += 1
      end
    end
  end

  class <<self

    def current_lang
      Lang.get VIM::evaluate("&ft")
    end

    def tmpfile(name)
      return "/tmp/#{name}" if FileTest.directory?("/tmp")
      return "C:\\temp\\#{name}" if FileTest.directory?("C:\\temp")
      raise 'No temp directory'
    end
    def problem_output_file
      tmpfile(problem_name+"_test.out")
    end
    def compile_and_fix
      VIM::command('write')
      system(current_lang.make_compile_command(VIM::Buffer.current.name, extra_flags, tmpfile('errors.vim')))
      if $? != 0
	VIM::command("cfile #{tmpfile('errors.vim')}")
	return false
      end
      true
    end

    def current_directory_prefix
      "." + (File::ALT_SEPARATOR || File::SEPARATOR)
    end

    def run_tests
      if File.exists?("run.sh")
	cmd = current_directory_prefix + "run.sh #{problem_name}"
      else
	cmd = current_lang.make_run_command(VIM::Buffer.current.name)
      end
      VIM::command('Sscratch')
      VIM::command('normal ggdG')
      VIM::command("silent read !#{cmd}")
      VIM::command('normal gg')
      VIM::command('redraw')
    end

    def test
      compile_and_fix && run_tests
    end

    def problem_name
      VIM::Buffer.current.name.gsub(/\.[a-z]+$/,'').gsub(/^.*[\/\\]/,'')
    end

    def debug
      return unless compile_and_fix
      File.open("/tmp/#{problem_name}.gdb", 'w') do |fh|
	fh << "break #{problem_name}.cpp:#{VIM::Window.current.cursor[0]}\n"
	fh << "run\n"
      end
      VIM::command("!gdb -x /tmp/#{problem_name}.gdb ./#{problem_name}")
    end

    def self.delegate_to_current_lang(sym)
      define_method(sym) do |*args|
        current_lang.send(sym, VimContext.new, *args)
      end
    end

    delegate_to_current_lang :setup_abbreviations
    delegate_to_current_lang :handle_abbreviation
    delegate_to_current_lang :new_file

    def extra_flags
      result = ''
      buf = VIM::Buffer.current
      buf.count.times do |i|
	if buf[i+1] =~ /@extra-flags:(.*);/ then
	  result << $1
	end
      end
      result
    end
   
  end
end

# vi:set ft=ruby sts=2 sw=2 ai et:
