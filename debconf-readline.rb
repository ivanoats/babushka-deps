dep 'debconf readline' do
    met? { } #how??
    meet? { log_shell 'dpkg-reconfigure debconf -f readline -p high' }
end
