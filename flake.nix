{
  description = "NixOS configuration";

  inputs = {
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    fesite = {
      url = "gitlab:/fetsorn/site/main";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hardwarepi.url = "github:nixos/nixos-hardware/master";
  };


  outputs = inputs@{ self, ... }:

    {
      homeConfigurations = {
        darwin = inputs.home-manager.lib.homeManagerConfiguration {
          stateVersion = "21.05";
          system = "aarch64-darwin";
          homeDirectory = "/Users/fetsorn";
          username = "fetsorn";

          configuration = { pkgs, ... }:
            {

              xdg.configFile."nixpkgs/nix.conf".text = builtins.readFile ./nix.conf;

              home.file.".doom.d/init.el".text = builtins.readFile ./doom-init.el;
              home.file.".doom.d/config.el".text = builtins.readFile ./doom-config.el;
              home.file.".doom.d/packages.el".text = builtins.readFile ./doom-packages.el;
              programs.home-manager.enable = true;

              programs.git = {
                enable = true;
                userName  = "Anton Davydov";
                userEmail = "fetsorn@gmail.com";
                    extraConfig = {
                      init = { defaultBranch = "main"; };
                      pull = { rebase = true; };
                    };
              };

              programs.zsh = {
                enable = true;
                initExtraFirst = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
              };

              home.file.".zshrc".text = builtins.readFile ./zshrc;
              home.file.".p10k.zsh".text = builtins.readFile ./p10k.zsh;

              home.sessionVariables.LC_ALL = "C";

              home.packages = with pkgs; [
                # utilities
                alacritty
                bat
                cmake
                coreutils
                emacs
                fd
                ripgrep
                jq
                tmux
                nixUnstable
                zsh-powerlevel10k
              ];

            }; # configuration
        };
      }; # homeConfigurations
      # fetsorn = self.homeConfigurations.darwin.activationPackage;
      # defaultPackage.x86_64-linux = self.fetsorn;

      nixosConfigurations.vm-arm = inputs.nixos-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules =
          [
            ({ pkgs, config, lib, modulesPath, ... }: {
              nix = {
                package = pkgs.nixUnstable;
                extraOptions = ''
                  experimental-features = nix-command flakes ca-references
                '';
              };

              boot.initrd.availableKernelModules = [ "ehci_pci" "xhci_pci" "usbhid" "sd_mod" "sr_mod" ];
              boot.initrd.kernelModules = [ ];
              boot.kernelModules = [ ];
              boot.extraModulePackages = [ ];

              fileSystems."/" =
                {
                  device = "/dev/disk/by-uuid/4653506c-3bff-4fbf-bdc6-af7e3f04721a";
                  fsType = "ext4";
                };

              fileSystems."/boot" =
                {
                  device = "/dev/disk/by-uuid/3C32-639C";
                  fsType = "vfat";
                };

              swapDevices = [ ];
              # Let 'nixos-version --json' know about the Git revision
              # of this flake.
              # system.configurationRevision = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
              system.configurationRevision =
                if self ? rev
                then self.rev
                else throw "Refusing to build from a dirty Git tree!";

              # Network configuration.

              networking.useDHCP = false;
              networking.interfaces.eth0.useDHCP = true;

              boot.loader.systemd-boot.enable = true;
              boot.loader.efi.canTouchEfiVariables = true;

              services.openssh.enable = true;

              services.xserver = {
                enable = true;
                displayManager = {
                  defaultSession = "none+xmonad";
                  lightdm.enable = true;
                  # lightdm.greeters.mini.enable = true;
                };
                windowManager.xmonad = {
                  enable = true;
                  enableContribAndExtras = true;
                };
              };

              users.users.fetsorn = {
                isNormalUser = true;
                password = "1234";
                extraGroups = [ "wheel" ];
              };
              users.mutableUsers = false;

              environment.systemPackages = with pkgs; [
                wget
                firefox
                rofi
                alacritty
                bat
              ];

            })
          ];
      };
      nixosConfigurations.vm-x86 = inputs.nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          [
            ({ pkgs, config, lib, modulesPath, ... }: {
              nix = {
                package = pkgs.nixUnstable;
                extraOptions = ''
                  experimental-features = nix-command flakes
                '';
              };

              boot.initrd.availableKernelModules = [ "ehci_pci" "uhci_hcd" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
              boot.initrd.kernelModules = [ ];
              boot.kernelModules = [ "kvm-amd" ];
              boot.extraModulePackages = [ ];

              fileSystems."/" =
                {
                  device = "/dev/disk/by-uuid/b907ec30-f267-4d35-8f61-2951a5203418";
                  fsType = "ext4";
                };

              fileSystems."/boot" =
                {
                  device = "/dev/disk/by-uuid/2BCB-AF29";
                  fsType = "vfat";
                };

              swapDevices =
                [{ device = "/dev/disk/by-uuid/caac48dd-00c5-4cf7-b7f9-11561882e417"; }];

              boot.loader.systemd-boot.enable = true;
              boot.loader.efi.canTouchEfiVariables = true;
              networking.useDHCP = false;
              networking.interfaces.enp0s7.useDHCP = true;
              services.xserver.enable = true;

              services.xserver.displayManager.defaultSession = "none+i3";
              services.xserver.desktopManager.xterm.enable = false;
              services.xserver.windowManager.i3 = {
                enable = true;
                extraPackages = with pkgs; [ dmenu i3status i3lock i3blocks ];
              };

              users.users.fetsorn = {
                isNormalUser = true;
                password = "1234";
                extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
              };
              users.mutableUsers = false;

              environment.systemPackages = with pkgs; [
                vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
                wget
              ];

              system.stateVersion = "21.05"; # Did you read the comment?

              # Let 'nixos-version --json' know about the Git revision
              # of this flake.
              # system.configurationRevision = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
              system.configurationRevision =
                if self ? rev
                then self.rev
                else throw "Refusing to build from a dirty Git tree!";

            })
          ];
      };
      nixosConfigurations.pi = inputs.nixos-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules =
          [
            inputs.hardwarepi.nixosModules.raspberry-pi-4
            ({ pkgs, config, lib, modulesPath, ... }: {

              nix = {
                package = pkgs.nixUnstable;
                extraOptions = ''
                  experimental-features = nix-command flakes
                '';
              };

              fileSystems = {
                "/" = {
                  device = "/dev/disk/by-label/NIXOS_SD";
                  fsType = "ext4";
                  options = [ "noatime" ];
                };
              };

              # Let 'nixos-version --json' know about the Git revision
              # of this flake.
              # system.configurationRevision = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
              system.configurationRevision =
                if self ? rev
                then self.rev
                else throw "Refusing to build from a dirty Git tree!";

              environment.systemPackages = with pkgs; [ vim ];

              services.openssh.enable = true;

              networking.firewall = {
                enable = true;
                allowedTCPPorts = [ 80 4000 ];
                allowedUDPPorts = [ 80 4000 ];
              };

              users = {
                mutableUsers = false;
                users.nixos = {
                  isNormalUser = true;
                  password = "1234";
                  extraGroups = [ "wheel" ];
                };
              };

              hardware.pulseaudio.enable = true;

            })
          ];
      };
      nixosConfigurations.aws-arm-simple = inputs.nixos-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules =
          [
            ({ pkgs, config, lib, modulesPath, ... }: {

              imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
              ec2.hvm = true;
              ec2.efi = true;

              nix = {
                package = pkgs.nixUnstable;
                extraOptions = ''
                  experimental-features = nix-command flakes ca-references
                '';
              };
              nixpkgs.config.allowUnfree = true;

              system.configurationRevision =
                if self ? rev
                then self.rev
                else throw "Refusing to build from a dirty Git tree!";

              services.openssh.enable = true;

              users.users.fetsorn = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
              };
              users.mutableUsers = false;

              environment.systemPackages = with pkgs; [
                wget
                vim
                ripgrep
              ];

              system.stateVersion = "21.05";

            })
          ];
      };
      nixosConfigurations.aws-arm-fesite = inputs.nixos-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules =
          [
            inputs.agenix.nixosModules.age
            ({ pkgs, config, lib, modulesPath, ... }:
              let
                overlays = [ (final: prev: { fesite = inputs.fesite.packages.aarch64-linux.fesite; }) ];
              in
              {
                imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
                ec2.hvm = true;
                ec2.efi = true;

                nix = {
                  package = pkgs.nixUnstable;
                  extraOptions = ''
                    experimental-features = nix-command flakes ca-references
                  '';
                };
                nixpkgs.config.allowUnfree = true;

                system.configurationRevision =
                  if self ? rev
                  then self.rev
                  else throw "Refusing to build from a dirty Git tree!";

                services.openssh.enable = true;

                users.users.fetsorn = {
                  isNormalUser = true;
                  extraGroups = [ "wheel" ];
                };

                nixpkgs.overlays = overlays;
                environment.systemPackages = with pkgs; [
                  wget
                  vim
                  fesite
                ];
                system.stateVersion = "21.05";
                # acme.nix
                security.acme.email = "me@fetsorn.website";
                security.acme.acceptTerms = true;

                age = {
                  secrets = {
                    acme-cf = {
                      file = ./secrets/acme-cf.age;
                      owner = "fetsorn";
                    };
                    site = {
                      file = ./secrets/site.age;
                      path = "/srv/within/fesite/.env";
                      owner = "fesite";
                      group = "within";
                      mode = "0400";
                    };
                  };
                };

                security.acme.certs."fetsorn.website" = {
                  group = "nginx";
                  email = "me@fetsorn.website";
                  dnsProvider = "cloudflare";
                  credentialsFile = "/run/secrets/acme-cf";
                  extraDomainNames = [ "*.fetsorn.website" ];
                  extraLegoFlags = [ "--dns.resolvers=8.8.8.8:53" ];
                };

                # site.nix
                users.users.fesite = {
                  createHome = true;
                  description = "github.com/fetsorn/site";
                  isSystemUser = true;
                  group = "within";
                  home = "/srv/within/fesite";
                  extraGroups = [ "keys" ];
                };

                systemd.services.fesite = {
                  wantedBy = [ "multi-user.target" ];

                  serviceConfig = {
                    User = "fesite";
                    Group = "within";
                    Restart = "on-failure";
                    WorkingDirectory = "/srv/within/fesite";
                    RestartSec = "30s";
                    Type = "notify";

                    # Security
                    CapabilityBoundingSet = "";
                    DeviceAllow = [ ];
                    NoNewPrivileges = "true";
                    ProtectControlGroups = "true";
                    ProtectClock = "true";
                    PrivateDevices = "true";
                    PrivateUsers = "true";
                    ProtectHome = "true";
                    ProtectHostname = "true";
                    ProtectKernelLogs = "true";
                    ProtectKernelModules = "true";
                    ProtectKernelTunables = "true";
                    ProtectSystem = "true";
                    ProtectProc = "invisible";
                    RemoveIPC = "true";
                    RestrictSUIDSGID = "true";
                    RestrictRealtime = "true";
                    SystemCallArchitectures = "native";
                    SystemCallFilter = [
                      "~@reboot"
                      "~@module"
                      "~@mount"
                      "~@swap"
                      "~@resources"
                      "~@cpu-emulation"
                      "~@obsolete"
                      "~@debug"
                      "~@privileged"
                    ];
                    UMask = "007";
                  };

                  script =
                    ''
                      export $(cat /srv/within/fesite/.env | xargs)
                      export SOCKPATH="/srv/within/run/fesite.sock"
                      export PORT=32837
                      export DOMAIN="fetsorn.website"
                      cd ${pkgs.fesite}
                      exec ${pkgs.fesite}/bin/fesite
                    '';
                };

                services.nginx.virtualHosts."fesite" = {
                  serverName = "fetsorn.website";
                  locations."/" = {
                    proxyPass = "http://unix:/srv/within/run/fesite.sock";
                    proxyWebsockets = true;
                  };
                  forceSSL = true;
                  useACMEHost = "fetsorn.website";
                  extraConfig = ''
                    access_log /var/log/nginx/fesite.access.log;
                  '';
                };

                networking.hostName = "lufta";

                networking.usePredictableInterfaceNames = false;

                nix = {
                  autoOptimiseStore = true;
                  useSandbox = true;
                  binaryCaches = [
                    "https://hydra.iohk.io"
                    "https://iohk.cachix.org"
                    "https://nix-community.cachix.org"
                  ];
                  binaryCachePublicKeys = [
                    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
                    "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
                    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                  ];
                  trustedUsers = [ "root" "fetsorn" ];
                };

                security.pam.loginLimits = [{
                  domain = "*";
                  type = "soft";
                  item = "nofile";
                  value = "unlimited";
                }];
                systemd.services.within-homedir-setup = {
                  description = "Creates homedirs for /srv/within services";
                  wantedBy = [ "multi-user.target" ];

                  serviceConfig.Type = "oneshot";

                  script = with pkgs; ''
                    ${coreutils}/bin/mkdir -p /srv/within
                    ${coreutils}/bin/chown root:within /srv/within
                    ${coreutils}/bin/chmod 775 /srv/within
                    ${coreutils}/bin/mkdir -p /srv/within/run
                    ${coreutils}/bin/chown root:within /srv/within/run
                    ${coreutils}/bin/chmod 770 /srv/within/run
                  '';
                };
                services.journald.extraConfig = ''
                  SystemMaxUse=100M
                  MaxFileSec=7day
                '';

                services.resolved = {
                  enable = true;
                  dnssec = "false";
                };

                services.lorri.enable = true;
                systemd.network = {
                  enable = true;
                };

                users.groups.within = { };

                systemd.services.nginx.serviceConfig.SupplementaryGroups = "within";
                services.nginx = {
                  enable = true;
                  recommendedGzipSettings = true;
                  recommendedOptimisation = true;
                  recommendedProxySettings = true;
                  recommendedTlsSettings = true;
                  statusPage = true;
                  enableReload = true;
                };

                services.mysql = {
                  enable = true;
                  package = pkgs.mariadb;
                  bind = "127.0.0.1";
                };

                networking.firewall = {
                  enable = true;
                  allowedTCPPorts = [ 22 80 443 1965 6667 6697 8009 8000 8080 3030 ];
                  allowedUDPPorts = [ 80 443 41641 51822 51820 ];

                  allowedUDPPortRanges = [{
                    from = 32768;
                    to = 65535;
                  }];
                };
              })
          ];
      };

      deploy.nodes.aws = {
        sshUser = "root";
        hostname = "34.219.138.142";
        sshOpts = [ "-i" "~/.ssh/nixos.pem" ];
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.aws-arm-simple;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;

      apps.aarch64-linux.deployApp = {
        type = "app";
        program = "${inputs.deploy-rs.packages.aarch64-linux.deploy-rs}/bin/deploy";
      };
      defaultApp.aarch64-linux = self.apps.aarch64-linux.deployApp;

    }; #outputs
}
