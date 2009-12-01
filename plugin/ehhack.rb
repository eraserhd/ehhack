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
  class Section
    def includes?(exp)
      buf = VIM::Buffer.current
      buf.count.times do |i|
	return true if buf[i+1] =~ exp
      end
      false
    end
    def include(source)
      buf = VIM::Buffer.current
      curs = VIM::Window.current.cursor
      inspt = insertion_point(buf, source)
      source.split(/\r?\n/).each do |line|
	buf.append(inspt, line)
	inspt += 1
	curs[0] += 1 if curs[0] > inspt
      end
      VIM::Window.current.cursor = curs
    end
  end
  class MacroSection <Section
    def insertion_point(buf, source)
      result = 0
      buf.count.times do |i|
	result = i+1 if buf[i+1] =~ /^#include / 
	result = i+1 if buf[i+1] =~ /^using / 
	result = i+1 if buf[i+1] =~ /^namespace .* = /
	result = i+1 if buf[i+1] =~ /^#define / && buf[i+1] < source
      end 
      result
    end
  end
  class IncludeSection <Section
    def insertion_point(buf, source)
      result = 0
      buf.count.times do |i|
	result = i+1 if buf[i+1] =~ /#include </ && buf[i+1] < source
      end
      result 
    end
  end
  class CodeSection <Section
    def insertion_point(buf, source)
      result = 0
      buf.count.times do |i|
	result = i+1 if buf[i+1] =~ /^using /
	result = i+1 if buf[i+1] =~ /^#define /
	result = i-1 if buf[i+1] =~ /^class /
      end
      result
    end
  end
  class NamespaceSection <Section
    def insertion_point(buf, source)
      result = 0
      buf.count.times do |i|
	result = i+1 if buf[i+1] =~ /^using /
      end
      result
    end
  end
  class LibraryCode
    attr_accessor :source, :triggered_by, :section
    attr_writer :detect
    def initialize(attrs)
      attrs.each{|k,v| send("#{k}=",v)}
    end
    def include
      section.include(source) unless section.includes?(detect)
    end
    def detect
      return @detect if @detect
      result = source
      result = $1 if result =~ /^(.*?)[\n\r]/
      Regexp.compile('^'+Regexp.escape(result)+'$')
    end
  end
  def self.library_code(attrs)
    @library_code ||= []
    @trigger_map ||= {}
    lc = LibraryCode.new(attrs)
    @library_code << lc
    lc.triggered_by.each do |kw|
      @trigger_map[kw] ||= []
      @trigger_map[kw] << lc
    end
  end
  def self.macro(source)
    source =~ /^#define ([$A-Za-z_]+)/
    library_code :source => source,
		 :section => MacroSection.new,
		 :triggered_by => [ $1.intern ]
  end
  def self.header(args)
    library_code :source => "#include <#{args.keys.first}>",
		 :section => IncludeSection.new,
		 :triggered_by => args.values.first
  end

  # Common macros
  macro '#define ALL(c) (c).begin(),(c).end()'
  macro '#define BEGIN {'
  macro '#define END }'
  macro '#define TR(c,i) for (typeof((c).begin()) i = (c).begin(); i != (c).end(); ++i)'

  # Bring in headers as we need them
  header :iostream => [ :cin, :cerr, :cout, :istream, :ostream, :endl, :flush ]
  header :iomanip => [ :setw, :setfill, :hex, :setprecision ]
  header :fstream => [ :ifstream, :ofstream, :fstream ]
  header :sstream => [ :istringstream, :ostringstream, :stringstream ]
  header :bitset => [ :bitset ]
  header :deque => [ :deque ]
  header :list => [ :list ]
  header :map => [ :map, :multimap ]
  header :queue => [ :queue, :priority_queue ]
  header :set => [ :set, :multiset ]
  header :slist => [ :slist ]
  header :stack => [ :stack ]
  header :string => [ :string, :basic_string, :char_traits, :getline ]
  header :vector => [ :vector, :bit_vector ]
  header :algorithm => [ :adjacent_find, :binary_search, :copy, :copy_backward, :count, :count_if, :equal,
			 :equal_range, :fill, :find, :find_end, :find_first_of, :find_if, :for_each,
			 :generate, :generate_n, :includes, :inplace_merge, :is_heap, :is_sorted,
			 :iter_swap, :lexicographical_compare, :lexicographical_compare_3way,
			 :lower_bound, :make_heap, :max, :max_element, :merge, :min, :min_element,
			 :mismatch, :next_permutation, :nth_element, :partial_sort, :partial_sort_copy,
			 :partition, :pop_heap, :prev_permutation, :push_heap, :random_sample,
			 :random_sample_n, :random_shuffle, :remove, :remove_copy, :remove_copy_if,
			 :remove_if, :replace, :replace_copy, :replace_copy_if, :replace_if, :reverse,
			 :reverse_copy, :rotate, :rotate_copy, :search, :search_n, :set_difference,
			 :set_intersection, :set_symmetric_difference, :set_union, :sort, :sort_heap,
			 :stable_partition, :stable_sort, :swap, :swap_ranges, :transform, :unique,
			 :unique_copy, :upper_bound ]
  header :numeric => [ :accumulate, :adjacent_difference, :inner_product, :partial_sum, :power ]
  header :iterator => [ :advance, :distance, :ostream_iterator, :istream_iterator, :front_insert_iterator,
		        :back_insert_iterator, :front_inserter, :back_inserter, :insert_iterator, :inserter,
			:reverse_iterator, :reverse_bidirectional_iterator ]
  header :functional => [ :plus, :minus, :multiplies, :divides, :modulus, :negate, :equal_to,
			  :not_equal_to, :less, :greater, :less_equal, :greater_equal, :logical_and,
			  :logical_or, :logical_not, :binder1st, :bind1st, :binder2nd, :bind2nd,
			  :ptr_fun, :pointer_to_unary_function, :pointer_to_binary_function, :not1,
			  :unary_negate, :binary_negate, :not2, :mem_fun, :mem_fun_ref, :mem_fun1,
			  :mem_fun1_ref ]
  header :utility => [ :pair, :make_pair ]
  header :exception => [ :exception, :bad_exception, :unexpected, :uncaught_exception, :terminate,
                         :set_unexpected, :set_terminate, :terminate_handler, :unexpected_handler ]
  header :stdexcept => [ :domain_error, :invaid_argument, :length_error, :out_of_range, :overflow_error,
                         :range_error, :underflow_error, :runtime_error ]
  header :cassert => [ :assert ]
  header :cctype => [ :isalnum, :isalpha, :iscntrl, :isdigit, :isgraph, :islower, :isprint, :ispunct,
                      :isspace, :isupper, :isxdigit, :tolower, :toupper ]
  header :cmath => [ :fmod ]
  header :cstdio => [ :fflush, :freopen, :setbuf, :setvbuf, :fprintf, :fscanf, :printf, :scanf, :sprintf,
		      :sscanf, :vfprintf, :vprintf, :vsprintf, :fgetc, :fgets, :fputc, :fputs, :getc,
		      :getchar, :gets, :putc, :putchar, :puts, :ungetc, :fread, :fwrite, :fseek, :ftell,
		      :rewind, :feof, :perror, :EOF, :FILE, :fpos_t ]
  header :cstdlib => [ :atof, :atoi, :atol, :strtod, :strtol, :strtoul, :rand, :srand, :abort, :exit,
		       :qsort, :abs, :atexit, :calloc, :bsearch, :div, :free, :malloc, :getenv, :labs,
		       :ldiv, :system ]
  header :cstring => [ :memcpy, :memmove, :strcpy, :strncpy, :strcat, :strncat, :memcmp, :strcmp,
                       :strcoll, :strncmp, :strxfrm, :memchr, :strchr, :strcspn, :strpbrk, :strrchr,
                       :strspn, :strstr, :strtok, :memset, :strerror, :strlen, :size_t, :NULL ]
  header 'unistd.h' => [ :getopt ]
  header 'gsl/gsl_rng.h' => [ :gsl_rng, :gsl_rng_alloc, :gsl_rng_set, :gsl_rng_free ]
  header 'limits.h' => [ :INT_MAX, :INT_MIN, :UINT_MAX, :LLONG_MAX, :ULONG_MAX ]
  header 'dirent.h' => [ :opendir, :readir ]
  header 'sys/types.h' => [ :dirent ]

  header 'ext/numeric' => [ :power ]
  header 'ext/algorithm' => [ :is_sorted ]

  library_code :triggered_by => [ :INF ], :section => CodeSection.new,
	       :detect => (/^const int INF/),
	       :source => "const int INF = 999999999;"
  
  library_code :triggered_by => [ :ufs_find, :ufs_merge ], :section => CodeSection.new,
	       :detect => (/^void ufs_merge\(/),
	       :source => <<EOF
vector<int> ufs(?:, 65535);

int ufs_find(int n) {
    if (ufs[n]%65536 == 65535)
	return n;
    return ufs[n] = ufs_find(ufs[n]%65536);
}

void ufs_merge(int l, int r) {
    int lv = ufs_find(l), rv = ufs_find(r);
    if (lv == rv)
	return;
    int ld = ufs[lv]/65536, rd = ufs[rv]/65536;
    if (ld < rd)
	ufs[lv] = rv;
    else if (rd < ld)
	ufs[rv] = lv;
    else {
	ufs[lv] = rv;
	ufs[rv] += 65536;
    }
}
EOF
  library_code :triggered_by => [ :split ], :section => CodeSection.new,
	       :detect => (/^vector<string> split\(/),
	       :source => <<EOF
vector<string> split(const string& s, const string& delim) {
    vector<string> result;
    string::size_type ofs = 0;
    while (ofs < s.size()) {
        string::size_type next = s.find(delim, ofs);
        if (next == string::npos)
            next = s.size();
        result.push_back(s.substr(ofs, next-ofs));
        ofs = next + delim.size();
    }
    return result;
}
EOF
  
  class <<self
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
      system(Lang.current.make_compile_command(VIM::Buffer.current.name, extra_flags, tmpfile('errors.vim')))
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
	cmd = Lang.current.make_run_command(VIM::Buffer.current.name)
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

    def setup_abbreviations
      if VIM::evaluate("&ft") == "cpp"
        @trigger_map.each_key do |kw|
          VIM::command("iab <buffer> <silent> #{kw} #{kw}"+
                       "<ESC>:ruby EhHack.include_library_code(:#{kw})<CR>a")
        end
      end
    end

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
   
    def include_library_code(name)
      return unless @trigger_map.has_key?(name)
      @trigger_map[name].each {|lc| lc.include}
    end

    def new_file
      template = <<EOF
using namespace std;

int main() {
    return 0;
}
EOF
      i = 0
      template.split(/\r?\n/).each do |line|
	VIM::Buffer.current.append(i, line)
	i += 1
      end
      VIM::Window.current.cursor = [3,11]
    end

  end
end

# vi:set ft=ruby sts=2 sw=2 ai et: