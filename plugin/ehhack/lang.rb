
EHHACK_LANG_PATH = File.dirname(__FILE__)+'/lang'

module EhHack
module Lang

  module BuildsNativeExe
    def make_run_command(sourcefile)
      exe_name(sourcefile)
    end

  private
    def windows?
      RUBY_PLATFORM.downcase.include?("mswin")
    end

    def exe_suffix
      if windows?
        ".exe"
      else
        ""
      end
    end

    def exe_name(sourcefile)
      sourcefile =~ /^(.*)\.[^\.]*$/
      name = "#{$1}#{exe_suffix}"
      name.gsub!(/\//, "\\") if windows?
      name
    end
  end

  class Lang

    # Override me to populate the contents of a new file of this language.
    def new_file(vim); end

    def setup_abbreviations(vim); end
    def handle_abbreviation(vim, name); end

  end

  def self.get(name)
    $EHHACK_LANG_CACHE ||= Hash.new
    if name == ''
      ft = :Text
    else
      ft = name.capitalize.intern
    end
    return $EHHACK_LANG_CACHE[ft] if $EHHACK_LANG_CACHE.has_key?(ft)
    if EhHack::Lang.const_defined?(ft)
      new_inst = EhHack::Lang.const_get(ft).new
    else
      # Unknown file type, supply a new Lang instance as a null object
      new_inst = EhHack::Lang::Lang.new
    end
    $EHHACK_LANG_CACHE[ft] = new_inst
    new_inst
  end

end
end

Dir.entries(EHHACK_LANG_PATH).select{|n| n =~ /\.rb$/}.each do |f|
  load "#{EHHACK_LANG_PATH}/#{f}"
end

