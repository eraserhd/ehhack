
module EhHack
module Lang


class Scala < Lang
  def make_compile_command(sourcefile, extra_flags, error_file)
    "scalac #{extra_flags} #{sourcefile} >#{error_file} 2>&1"
  end

  def make_run_command(sourcefile)
    "scala #{class_name(sourcefile)}"
  end

  def new_file
    object = class_name(VIM::Buffer.current.name)
    replace_buffer_with_template <<EOF

object #{object} {
  def main(args: Array[String]) = {
  }
}
EOF
    VIM::Window.current.cursor = [3,35]
  end

private
  def class_name(sourcefile)
    sourcefile =~ /^(.*)\.[^\.]*$/
    File.basename($1)
  end

end


end
end
