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

# vim: ft=ruby
