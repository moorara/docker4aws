workflow "Main" {
  on = "push"
  resolves = [ "Validate" ]
}

action "Validate" {
  uses = "docker://hashicorp/packer:light"
  args = [ "version" ]
}
