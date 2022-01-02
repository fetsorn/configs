# EDITOR=vim nix run github:ryantm/agenix -- -e file.age --identity ~/key.gpg
let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMbaFqqx1dTLTbBCKuoJDP6scKi4lLH8AjgrZqrKQJML your_email@example.com";
  users = [ user1 ];
  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEy1daQszYazJ35NTCvKrbTRVOYy3495wCBtvF+65zSk root@ip-172-31-11-231.us-west-2.compute.internal";
  system2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbxMYl5IfRznpvsBrmTIcC1WiLx/1H21NR0c3N2Ncrk root@nixos";
  systems = [ system1 ];
in { 
  "site.age".publicKeys = systems ++ users; 
  "acme-cf.age".publicKeys = systems ++ users;
  "testmailpass.age".publicKeys = [ user1 system2 ];
}



