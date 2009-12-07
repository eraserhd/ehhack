
module EhHack
module Lang


class Cpp < Lang
  include BuildsNativeExe

  def make_compile_command(sourcefile, extra_flags, error_file)
    "#{compiler} -g -Wno-deprecated #{extra_flags} -o #{exe_name(sourcefile)} #{sourcefile} >#{error_file} 2>&1"
  end

  def header?
    VIM::Buffer.current.name =~ /\.(h|hpp|hxx|hh)$/
  end

  def new_file
    if header?
      guard = File.basename(VIM::Buffer.current.name).gsub(/[^a-zA-Z0-9_]/, "_") + "_INCLUDED"
      replace_buffer_with_template <<EOF
#ifndef #{guard}
#define #{guard}


#endif // ndef #{guard}
EOF
      VIM::Window.current.cursor = [3,1]
    else
      replace_buffer_with_template <<EOF
using namespace std;

int main() {
    return 0;
}
EOF
      VIM::Window.current.cursor = [3,11]
    end
  end

  def iscsym?(c)
    (c >= ?a && c <= ?z) || (c >= ?A && c <= ?Z) || (c >= ?0 && c <= ?9) || (c == ?_)
  end

  def current_line
    VIM::Buffer.current[VIM::Window.current.cursor[0]]
  end

  def char_preceding_keyword
    line = current_line
    col = VIM::Window.current.cursor[1]-1
    col -= 1 while col > 0 and iscsym?(line[col])
    line[col]
  end

  def valid_keyword_instance?
    return false if char_preceding_keyword == ?.
    return false if current_line =~ /^\s*#\s*include[^a-zA-Z0-9_]/
    true
  end

private
  def compiler
    $CXX_COMPILER || "g++"
  end

end
  

end
end
