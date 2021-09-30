let 
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMbaFqqx1dTLTbBCKuoJDP6scKi4lLH8AjgrZqrKQJML your_email@example.com";
  users = [ user1 ];
  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEy1daQszYazJ35NTCvKrbTRVOYy3495wCBtvF+65zSk root@ip-172-31-11-231.us-west-2.compute.internal"; 
  systems = [ system1 ]; 
in { 
  "site.age".publicKeys = systems ++ users; 
  "acme-cf.age".publicKeys = systems ++ users; 
}



