dep postfix.managed do
  met? { which "mail" }
  meet do
    installs { via :apt, "postfix telnet mailx" }
  end
end
