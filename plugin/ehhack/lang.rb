
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
  end

  def self.get(name)
    $EHHACK_LANG_CACHE ||= Hash.new
    ft = name.capitalize.intern
    return $EHHACK_LANG_CACHE[ft] if $EHHACK_LANG_CACHE.has_key?(ft)
    return nil unless EhHack::Lang.const_defined?(ft)
    new_inst = EhHack::Lang.const_get(ft).new
    $EHHACK_LANG_CACHE[ft] = new_inst
    new_inst
  end

  def self.current
    get VIM::evaluate("&ft")
  end

end
end

Dir.entries(EHHACK_LANG_PATH).select{|n| n =~ /\.rb$/}.each do |f|
  load "#{EHHACK_LANG_PATH}/#{f}"
end

