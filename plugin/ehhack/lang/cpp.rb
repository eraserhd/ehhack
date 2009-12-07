
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

private
  def compiler
    $CXX_COMPILER || "g++"
  end

end
  

end
end
