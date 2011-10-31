dep postfix.managed {
met? { which "mail" }
meet do
  installs { via :apt, "postfix telnet mailx" }
end
