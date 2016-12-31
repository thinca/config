IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:AUTO_INDENT] = true
IRB.conf[:PROMPT][:SIMPLE] = {
  :PROMPT_I => "%03n:>> ",
  :PROMPT_N => "%03n:%i>",
  :PROMPT_S => "%03n:>%l ",
  :PROMPT_C => "%03n:>> ",
  :RETURN => "=> %s\n"
}
IRB.conf[:PROMPT_MODE] = :SIMPLE


alias q exit

begin
  # load libraries
  require 'irb/completion'
  require 'pp'
  require 'rubygems'
  require 'wirble'

  # start wirble
  Wirble.init
  # Can't use color in windows.
  unless RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/
    # with color
    Wirble.colorize
  end
rescue
end

# vim: ft=ruby
