
module EhHack
module Lang


class Java < Lang
  def make_compile_command(sourcefile, extra_flags, error_file)
    "javac #{extra_flags} #{sourcefile} >#{error_file} 2>&1"
  end

  def make_run_command(sourcefile)
    "java #{class_name(sourcefile)}"
  end

  def new_file(vim)
    klass = class_name(vim.buffer.name)
    vim.replace_buffer_with_template <<EOF
import java.io.*;

public class #{klass} {
  
    public static void main(String[] args) {
        try {
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
EOF
    vim.window.cursor = [6,12]
  end

private
  def class_name(sourcefile)
    sourcefile =~ /^(.*)\.[^\.]*$/
    File.basename($1)
  end

end


end
end
