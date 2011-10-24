# chef client via apt
dep("chef client from apt") {
  requires {
    on :ubuntu, 'hostname', 'opscode apt source added', 'chef.managed'
  }
}

