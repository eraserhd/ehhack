
module EhHack
module Lang

class Haskell < Lang
  include BuildsNativeExe

  def make_compile_command(sourcefile, extra_flags, error_file)
    "ghc #{extra_flags} --make #{sourcefile} >#{error_file} 2>&1"
  end
end

end
end
