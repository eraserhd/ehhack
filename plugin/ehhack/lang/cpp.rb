
module EhHack
module Lang


class Cpp < Lang
  include BuildsNativeExe

  def make_compile_command(sourcefile, extra_flags, error_file)
    "#{compiler} -g -Wno-deprecated #{extra_flags} -o #{exe_name(sourcefile)} #{sourcefile} >#{error_file} 2>&1"
  end

private
  def compiler
    $CXX_COMPILER || "g++"
  end

end
  

end
end
