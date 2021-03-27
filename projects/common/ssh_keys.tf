module "alesh_rsa_key" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "alesh-rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAqrEQFa8Im1tydF7YIVbGPX3Vt96qLIUqa7lzN/bZLR6JlkPiZ0AswX29OaUMVWvZtp92ixsP7X1qi4E1d7btDnWdqTWSGrm/t4i+KX9HV6AXAOWFUSXpMukmDrGGCBKf+8k6p8k49tkDMBzgeOeEIwJ6oQKB6HsANXYGw+9LeoM= alesh-rsa"

}

module "bot_ci_ansible_rsa_key" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "bot-ci-ansible-rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVZVMnmAe8rH+D9Hro7+E3iYHq1UGAVD4ArvDpdl+EiXuQk0lvF4qZOAKsn/kk3jl5JaWM0LrtT96W06mXrllLzXoMQ3vy2j2r097pmRAY8KG2LkuLu46MH16DzB0QZ/jf0dJPf1kJ1pZsxvLc71/3r1X4pZRLg46X2XIbhOvivXRxAe43UcWNfq8WpbrW/ej9l1Ed/+azEas3Pv+Stq9QRK0yCENOhUO7j8tFY2ro1Hf5zy6WUAyEGI0grkAWVCp4xis172BhNaDL0Ra3ZcqX/S495IeVobwpXD+xOO98xC6vL6atIqHiVxp11UzHnXFBqrGeVKgrv4SjcuhvTgar ansible-bot@osamaoracle"

}
