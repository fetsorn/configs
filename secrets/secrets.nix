# EDITOR=vim nix run github:ryantm/agenix -- -e file.age --identity ~/key.gpg
let
  id_rsa_agenix = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvQ8XQYIemNkp5AhNnXHjA0POQ8RgQMxZu5o4ryI79AD6lClrjFbfpSWWG7/EMnAp8pyz88lNxRsMDIvaZLhQB84FPunoKfkIp+l7iX6k0b3BZ3bGp+v1irj08SBpXsTI2IaUyED2ECzl+XT4rzZ+0raQ2lgfo3WPJ5+ZorXuWHsNa+rW14EbhGlNiPiUP7ynW/RwDMiwPJKQ86CY9Age1RGytfHu3SB3CC4zZjELI/5DLmh7tQZz6uG3ALiGTC1K2+ga9GQ1AQh6jJPm3MRar0V8V/hsIIOAYNPlnrxvo7r+womw3vD0IRzQHoTQeYLsizmVsGMnQzBLUXhDZn1jtboiyTSiIqm3whsia8VqPIs4Zsdpy0ohKbTZ7shmO9foC6Q9B4F1vMW33AB28NwpNG4LgPWR1l7a2LK1qaB5vr0GELZmBmCxVRFZvbk77JoovWMZypheVGg4qDHPukiEPgckymwK6/MB3VhwyvFpPvyLAq7v7Tz7q8Ru6FxWC8Es= fetsorn@darwin.local";
  linode_mail = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbxMYl5IfRznpvsBrmTIcC1WiLx/1H21NR0c3N2Ncrk root@nixos";
in {
  "site.age".publicKeys = [ id_rsa_agenix ];
  "acme-cf.age".publicKeys = [ id_rsa_agenix ];
  "mail-git.age".publicKeys = [ id_rsa_agenix linode_mail ];
  "mail-anton.age".publicKeys = [ id_rsa_agenix linode_mail ];
  "mail-fetsorn.age".publicKeys = [ id_rsa_agenix linode_mail ];
}



