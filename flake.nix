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
    simple-nixos-mailserver.url =
      "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
  };

  outputs = inputs@{ self, ... }: {
    homeConfigurations = {
      darwin = inputs.home-manager.lib.homeManagerConfiguration {
        stateVersion = "21.11";
        system = "aarch64-darwin";
        homeDirectory = "/Users/fetsorn";
        username = "fetsorn";
        configuration = { pkgs, lib, ... }:
          let
            llines = (with pkgs;
              stdenv.mkDerivation rec {
                pname = "lifelines";
                version = "unstable-2021-11-22";

                src = fetchFromGitHub {
                  owner = pname;
                  repo = pname;
                  rev = "a5a54e8";
                  sha256 = "tqggAcYRRxtPjTLc+YJphYWdqfWxMG8V/cBOpMTiZ9I=";
                };

                buildInputs = [ gettext libiconv ncurses perl ];
                nativeBuildInputs = [ autoreconfHook bison ];

                meta = with lib; {
                  description = "Genealogy tool with ncurses interface";
                  homepage = "https://lifelines.github.io/lifelines/";
                  license = licenses.mit;
                  platforms = platforms.darwin;
                };
              });
            noisegen = pkgs.writeShellScriptBin "noisegen" ''
              set -u
              set -e

              minutes=''${1:-'59'}
              repeats=$(( minutes - 1 ))
              center=''${2:-'1786'}

              wave=''${3:-'0.0333333'}

              noise='brown'

              len='01:00'

              if [ $minutes -eq 1 ] ; then
                   progress='--show-progress'
              else
                   progress='--no-show-progress'
              fi

              printf "%s\n" " ::  Please stand-by... sox will 'play' $noise noise for $minutes minute(s)."

              ${pkgs.sox}/bin/play $progress  -c 2  --null  -t coreaudio  synth  $len  ''${noise}noise  \
                   band -n $center 499               \
                   tremolo $wave    43   reverb 19   \
                   bass -11              treble -1   \
                   vol     14dB                      \
                   repeat  $repeats

              exit 0
            '';
            maildir = "/Users/fetsorn/Maildir";
          in {
            accounts.email = {
              maildirBasePath = "${maildir}";
              accounts = let
                mailaccount = { name, primary ? false }: {
                  address = "${name}@fetsorn.website";
                  userName = "${name}@fetsorn.website";
                  passwordCommand = "${pkgs.pass}/bin/pass mail-${name}";
                  primary = primary;
                  mu.enable = true;
                  mbsync = {
                    enable = true;
                    create = "both";
                    expunge = "both";
                    patterns = [ "*" ];
                    extraConfig.account = {
                      CertificateFile = "${./secrets/ca-certificate}";
                    };
                  };
                  imap = {
                    host = "mail.fetsorn.website";
                    port = 993;
                    tls.enable = true;
                  };
                  realName = "Anton Davydov";
                  msmtp = {
                    enable = true;
                    # openssl s_client -connect mail.fetsorn.website:587 -starttls smtp < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout | cut -d'=' -f2
                    tls.fingerprint =
                      "74:A3:AD:1A:55:E9:A7:80:25:A5:E7:36:65:CE:C1:AB:8C:FC:AF:89";
                  };
                  smtp = {
                    host = "mail.fetsorn.website";
                    port = 587;
                    tls.useStartTls = true;
                  };
                };
              in {
                anton = mailaccount {
                  name = "anton";
                  primary = true;
                };
                auth = mailaccount { name = "auth"; };
                git = mailaccount { name = "git"; };
                fetsorn = mailaccount { name = "fetsorn"; };
              };
            };

            home = {
              file = {
                ".p10k.zsh".source = ./dotfiles/p10k.zsh;
                ".doom.d/init.el".source = ./dotfiles/doom-init.el;
                ".doom.d/config.el".source = ./dotfiles/doom-config.el;
                ".doom.d/packages.el".source = ./dotfiles/doom-packages.el;
                ".hammerspoon/init.lua".source = ./dotfiles/init.lua;
                ".hammerspoon/loopstop.lua".source = ./dotfiles/loopstop.lua;
              };

              packages = with pkgs; [
                ((emacsPackagesNgGen emacs).emacsWithPackages
                  (epkgs: [ epkgs.vterm ]))
                coreutils
                exa
                git-lfs
                fd
                ffmpeg
                jq
                llines
                nixfmt
                nixUnstable
                noisegen
                parallel
                ripgrep
                rsync
                tmux
                tree
                zsh-powerlevel10k
              ];

              sessionVariables = {
                LC_ALL = "en_US.utf-8";
                LANG = "en_US.utf-8";
              };
            };

            programs = {
              home-manager.enable = true;

              git = {
                enable = true;
                userName = "Anton Davydov";
                userEmail = "fetsorn@gmail.com";
                extraConfig = {
                  init = { defaultBranch = "main"; };
                  pull = { rebase = false; };
                };
              };

              gpg.enable = true;

              mbsync.enable = true;
              msmtp.enable = true;
              mu.enable = true;

              password-store.enable = true;

              zsh = {
                enable = true;
                initExtraFirst =
                  "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
                initExtra = builtins.readFile ./dotfiles/zshrc;
              };

            };
          }; # configuration
      }; # darwin

      fetsorn = inputs.home-manager.lib.homeManagerConfiguration {
        stateVersion = "21.11";
        system = "x86_64-linux";
        homeDirectory = "/home/fetsorn";
        username = "fetsorn";
        configuration = { pkgs, ... }: {

          xdg.configFile."nixpkgs/nix.conf".text =
            builtins.readFile ./dotfiles/nix.conf;

          home = {
            file = {
              ".p10k.zsh".text = builtins.readFile ./dotfiles/p10k.zsh;
              ".doom.d/init.el".text =
                builtins.readFile ./dotfiles/doom-init.el;
              ".doom.d/config.el".text =
                builtins.readFile ./dotfiles/doom-config.el;
              ".doom.d/packages.el".text =
                builtins.readFile ./dotfiles/doom-packages.el;
              ".xmonad/xmonad.hs".text = builtins.readFile ./dotfiles/xmonad.hs;
            };

            packages = with pkgs; [
              ((emacsPackagesNgGen emacs).emacsWithPackages
                (epkgs: [ epkgs.vterm ]))
              alacritty
              bat
              cabal-install
              clang
              cmake
              coreutils
              fd
              file
              firefox
              ghc
              git
              gnupg
              joshuto
              jq
              man-pages
              moreutils # for sponge
              ripgrep
              rsync
              rxvt_unicode
              termite
              tmux
              unzip
              vim
              vlc
              w3m
              wget
              which
              xclip
              zsh-powerlevel10k
            ];

            sessionVariables = {
              LC_ALL = "en_US.utf-8";
              LANG = "en_US.utf-8";
            };
          }; # home

          programs = {
            home-manager.enable = true;

            git = {
              enable = true;
              userName = "Anton Davydov";
              userEmail = "fetsorn@gmail.com";
              extraConfig = {
                init = { defaultBranch = "main"; };
                pull = { rebase = false; };
              };
            };

            zsh = {
              enable = true;
              initExtraFirst =
                "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
              initExtra = builtins.readFile ./dotfiles/zshrc;
            };
          };
        }; # configuration
      }; # fetsorn
    }; # homeConfigurations

    nixosConfigurations = {
      vm-arm = inputs.nixos-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ({ pkgs, config, lib, modulesPath, ... }: {
            nix = {
              package = pkgs.nixUnstable;
              extraOptions = "experimental-features = nix-command flakes";
            };
            nixpkgs.config.allowUnfree = true;

            boot = {
              initrd = {
                availableKernelModules =
                  [ "ehci_pci" "xhci_pci" "usbhid" "sd_mod" "sr_mod" ];
                kernelModules = [ ];
              };
              kernelModules = [ ];
              extraModulePackages = [ ];
              loader = {
                systemd-boot.enable = true;
                efi.canTouchEfiVariables = true;
              };
            };

            swapDevices = [ ];

            disabledModules = [ "virtualisation/parallels-guest.nix" ];
            imports = [ ./parallels-unfree/parallels-guest.nix ];
            hardware.parallels = {
              enable = true;
              package = (config.boot.kernelPackages.callPackage
                ./parallels-unfree/prl-tools.nix { });
            };

            fileSystems = {
              "/" = {
                device =
                  "/dev/disk/by-uuid/4653506c-3bff-4fbf-bdc6-af7e3f04721a";
                fsType = "ext4";
              };

              "/boot" = {
                device = "/dev/disk/by-uuid/3C32-639C";
                fsType = "vfat";
              };
            };

            environment.systemPackages = with pkgs; [
              alacritty
              bat
              firefox
              rofi
              wget
            ];

            services = {
              openssh.enable = true;
              xserver = {
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
            };

            networking = {
              useDHCP = false;
              interfaces.eth0.useDHCP = true;
              firewall = {
                enable = true;
                allowedTCPPorts = [ 3030 ];
              };
            };

            users = {
              mutableUsers = false;
              users.fetsorn = {
                isNormalUser = true;
                password = "1234";
                extraGroups = [ "wheel" ];
              };
            };

            system = {
              stateVersion = "21.11"; # Did you read the comment?
              configurationRevision = if self ? rev then
                self.rev
              else
                throw "Refusing to build from a dirty Git tree!";
            };

          })
        ];
      }; # vm-arm

      vm-x86 = inputs.nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, config, lib, modulesPath, ... }: {
            nix = {
              package = pkgs.nixUnstable;
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
              extraOptions = "experimental-features = nix-command flakes";
            };

            boot = {
              initrd = {
                availableKernelModules = [
                  "ehci_pci"
                  "uhci_hcd"
                  "ahci"
                  "usb_storage"
                  "usbhid"
                  "sd_mod"
                  "sr_mod"
                ];
                kernelModules = [ ];
              };
              kernelModules = [ "kvm-amd" ];
              extraModulePackages = [ ];
              loader = {
                systemd-boot.enable = true;
                efi.canTouchEfiVariables = true;
              };
            };

            fileSystems = {
              "/" = {
                device =
                  "/dev/disk/by-uuid/b907ec30-f267-4d35-8f61-2951a5203418";
                fsType = "ext4";
              };
              "/boot" = {
                device = "/dev/disk/by-uuid/2BCB-AF29";
                fsType = "vfat";
              };
            };

            swapDevices = [{
              device = "/dev/disk/by-uuid/caac48dd-00c5-4cf7-b7f9-11561882e417";
            }];

            environment.systemPackages = with pkgs; [ vim wget ];

            networking = {
              useDHCP = false;
              interfaces.enp0s7.useDHCP = true;
            };

            services.xserver = {
              enable = true;
              displayManager.defaultSession = "none+i3";
              desktopManager.xterm.enable = false;
              windowManager.i3 = {
                enable = true;
                extraPackages = with pkgs; [ dmenu i3status i3lock i3blocks ];
              };
            };

            users = {
              mutableUsers = false;
              users.fetsorn = {
                isNormalUser = true;
                password = "1234";
                extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
              };
            };

            system = {
              stateVersion = "21.11"; # Did you read the comment?
              configurationRevision = if self ? rev then
                self.rev
              else
                throw "Refusing to build from a dirty Git tree!";
            };

          })
        ];
      }; # vm-x86

      pi = inputs.nixos-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          inputs.hardwarepi.nixosModules.raspberry-pi-4
          ({ pkgs, config, lib, modulesPath, ... }: {

            nix = {
              package = pkgs.nixUnstable;
              extraOptions = "experimental-features = nix-command flakes";
            };
            nixpkgs.config.allowUnfree = true;

            fileSystems = {
              "/" = {
                device = "/dev/disk/by-label/NIXOS_SD";
                fsType = "ext4";
                options = [ "noatime" ];
              };
            };

            system = {
              stateVersion = "21.11"; # Did you read the comment?
              configurationRevision = if self ? rev then
                self.rev
              else
                throw "Refusing to build from a dirty Git tree!";
            };

            environment.systemPackages = with pkgs; [
              git
              ntfs3g
              rsync
              tmux
              vim
            ];

            services.openssh.enable = true;

            networking = {
              hostName = "pi";
              firewall = {
                enable = true;
                allowedTCPPorts = [ 4000 3000 ];
              };
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
      }; # pi

      aws-arm-simple = inputs.nixos-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ({ pkgs, config, lib, modulesPath, ... }: {

            imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
            ec2.hvm = true;
            ec2.efi = true;

            nix = {
              package = pkgs.nixUnstable;
              extraOptions = "experimental-features = nix-command flakes";
            };
            nixpkgs.config.allowUnfree = true;

            services.openssh.enable = true;

            users = {
              users.fetsorn = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
              };
              mutableUsers = false;
            };

            environment.systemPackages = with pkgs; [ ripgrep vim wget ];

            system = {
              stateVersion = "21.11";
              configurationRevision = if self ? rev then
                self.rev
              else
                throw "Refusing to build from a dirty Git tree!";
            };
          })
        ];
      }; # aws-arm-simple

      aws-arm-fesite = inputs.nixos-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ({ pkgs, config, lib, modulesPath, ... }:
            let
              overlays = [
                (final: prev: {
                  fesite = inputs.fesite.packages.aarch64-linux.fesite;
                })
              ];
            in {
              imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
              ec2 = {
                hvm = true;
                efi = true;
              };

              nix = {
                package = pkgs.nixUnstable;
                extraOptions = "experimental-features = nix-command flakes";
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
              nixpkgs.config.allowUnfree = true;

              system = {
                configurationRevision = if self ? rev then
                  self.rev
                else
                  throw "Refusing to build from a dirty Git tree!";
                stateVersion = "21.11";
              };

              nixpkgs.overlays = overlays;

              environment.systemPackages = with pkgs; [ fesite vim wget ];

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

              security = {
                acme = {
                  email = "me@fetsorn.website";
                  acceptTerms = true;
                  certs."fetsorn.website" = {
                    group = "nginx";
                    email = "me@fetsorn.website";
                    dnsProvider = "cloudflare";
                    credentialsFile = "/run/secrets/acme-cf";
                    extraDomainNames = [ "*.fetsorn.website" ];
                    extraLegoFlags = [ "--dns.resolvers=8.8.8.8:53" ];
                  };
                };
                pam.loginLimits = [{
                  domain = "*";
                  type = "soft";
                  item = "nofile";
                  value = "unlimited";
                }];
              };

              users = {
                groups.within = { };
                users = {
                  fetsorn = {
                    isNormalUser = true;
                    extraGroups = [ "wheel" ];
                  };

                  fesite = {
                    createHome = true;
                    description = "github.com/fetsorn/site";
                    isSystemUser = true;
                    group = "within";
                    home = "/srv/within/fesite";
                    extraGroups = [ "keys" ];
                  };
                };
              };

              systemd = {
                services = {
                  within-homedir-setup = {
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
                  nginx.serviceConfig.SupplementaryGroups = "within";
                  fesite = {
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

                    script = ''
                      export $(cat /srv/within/fesite/.env | xargs)
                      export SOCKPATH="/srv/within/run/fesite.sock"
                      export PORT=32837
                      export DOMAIN="fetsorn.website"
                      cd ${pkgs.fesite}
                      exec ${pkgs.fesite}/bin/fesite
                    '';
                  };
                };
                network.enable = true;
              };

              services = {
                openssh.enable = true;

                nginx = {
                  enable = true;
                  recommendedGzipSettings = true;
                  recommendedOptimisation = true;
                  recommendedProxySettings = true;
                  recommendedTlsSettings = true;
                  statusPage = true;
                  enableReload = true;
                  virtualHosts."fesite" = {
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
                };
                journald.extraConfig = ''
                  SystemMaxUse=100M
                  MaxFileSec=7day
                '';
                resolved = {
                  enable = true;
                  dnssec = "false";
                };
                lorri.enable = true;
                mysql = {
                  enable = true;
                  package = pkgs.mariadb;
                  bind = "127.0.0.1";
                };
              };

              networking = {
                hostName = "lufta";
                usePredictableInterfaceNames = false;
                firewall = {
                  enable = true;
                  allowedTCPPorts =
                    [ 22 80 443 1965 6667 6697 8009 8000 8080 3030 ];
                  allowedUDPPorts = [ 80 443 41641 51822 51820 ];

                  allowedUDPPortRanges = [{
                    from = 32768;
                    to = 65535;
                  }];
                };
              };
            }) # configuration
        ]; # modules
      }; # aws-arm-fesite

      linode-mail = inputs.nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ({ pkgs, config, lib, modulesPath, ... }: {

            imports = [
              (modulesPath + "/profiles/qemu-guest.nix")
              inputs.simple-nixos-mailserver.nixosModule
            ];

            boot = {
              initrd = {
                availableKernelModules =
                  [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];
                kernelModules = [ ];
              };
              extraModulePackages = [ ];
              loader = {
                timeout = 10;
                grub = {
                  enable = true;
                  version = 2;
                  extraConfig = ''
                    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
                    terminal_input serial;
                    terminal_input serial
                  '';
                  forceInstall = true;
                  device = "nodev";
                };
              };
              kernelModules = [ ];
              kernelParams = [ "console=ttyS0,19200n8" ];
            };

            fileSystems."/" = {
              device = "/dev/sda";
              fsType = "ext4";
            };

            swapDevices = [{ device = "/dev/sdb"; }];

            security.acme = {
              acceptTerms = true;
              email = "anton@fetsorn.website";
            };

            age = {
              secrets = {
                mail-anton = {
                  file = ./secrets/mail-anton.age;
                  owner = "fetsorn";
                };
                mail-auth = {
                  file = ./secrets/mail-auth.age;
                  owner = "fetsorn";
                };
                mail-fetsorn = {
                  file = ./secrets/mail-fetsorn.age;
                  owner = "fetsorn";
                };
                mail-git = {
                  file = ./secrets/mail-git.age;
                  owner = "fetsorn";
                };
              };
            };

            mailserver = {
              enable = true;
              fqdn = "mail.fetsorn.website";
              domains = [ "fetsorn.website" ];
              # nix run nixpkgs#apacheHttpd -- -c htpasswd -nbB "" "super secret password"
              loginAccounts = {
                "anton@fetsorn.website" = {
                  hashedPasswordFile = "/run/agenix/mail-anton";
                };
                "auth@fetsorn.website" = {
                  hashedPasswordFile = "/run/agenix/mail-auth";
                };
                "fetsorn@fetsorn.website" = {
                  hashedPasswordFile = "/run/agenix/mail-fetsorn";
                };
                "git@fetsorn.website" = {
                  hashedPasswordFile = "/run/agenix/mail-git";
                };
              };
              certificateScheme = 3;
              virusScanning = false; # breaks otherwise for some reason
            };

            networking = {
              usePredictableInterfaceNames = false;
              useDHCP = false;
              interfaces.eth0.useDHCP = true;
            };

            services.openssh = {
              enable = true;
              permitRootLogin = "no";
            };

            nix = {
              package = pkgs.nixUnstable;
              extraOptions = "experimental-features = nix-command flakes";
            };
            nixpkgs.config.allowUnfree = true;

            system = {
              configurationRevision = if self ? rev then
                self.rev
              else
                throw "Refusing to build from a dirty Git tree!";
              stateVersion = "21.11";
            };

            environment.systemPackages = with pkgs; [
              git
              inetutils
              mtr
              ripgrep
              rsync
              sysstat
              vim
              wget
            ];

            users = {
              users.fetsorn = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
              };
              mutableUsers = true;
            };
          })
        ];
      }; # linode-mail

      linode-gitea = inputs.nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ({ pkgs, config, lib, modulesPath, ... }: {

            imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

            boot = {
              initrd = {
                availableKernelModules =
                  [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];
                kernelModules = [ ];
              };
              extraModulePackages = [ ];
              loader = {
                timeout = 10;
                grub = {
                  enable = true;
                  version = 2;
                  extraConfig = ''
                    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
                    terminal_input serial;
                    terminal_input serial
                  '';
                  forceInstall = true;
                  device = "nodev";
                };
              };
              kernelModules = [ ];
              kernelParams = [ "console=ttyS0,19200n8" ];
            };

            fileSystems."/" = {
              device = "/dev/sda";
              fsType = "ext4";
            };

            swapDevices = [{ device = "/dev/sdb"; }];

            security.acme = {
              acceptTerms = true;
              email = "anton@fetsorn.website";
            };

            age = {
              secrets = {
                gitea-dbpass = {
                  file = ./secrets/gitea-dbpass.age;
                  owner = "fetsorn";
                  mode = "0444";
                  group = "gitea";
                };
              };
            };

            services.gitea = {
              enable = true;
              database = {
                type = "postgres";
                passwordFile = "/run/agenix/gitea-dbpass";
              };
              lfs.enable = true;
              domain = "source.fetsorn.website";
              rootUrl = "https://source.fetsorn.website/";
              httpPort = 3001;
              settings = {
                repository = {
                  ACCESS_CONTROL_ALLOW_ORIGIN = "https://antea.fetsorn.website";
                };
                cors = {
                  ENABLED = true;
                  ALLOW_CREDENTIALS = true;
                };
              };
            };

            services.postgresql = {
              enable = true;
              authentication = ''
                local gitea all ident map=gitea-users
              '';
              identMap = ''
                gitea-users gitea gitea
              '';
            };

            services.nginx = {
              enable = true;
              recommendedGzipSettings = true;
              recommendedOptimisation = true;
              recommendedProxySettings = true;
              recommendedTlsSettings = true;
              clientMaxBodySize = "100m";
              virtualHosts."source.fetsorn.website" = {
                enableACME = true;
                forceSSL = true;
                locations."/".proxyPass = "http://localhost:3001/";
                locations."/".extraConfig = ''
                  if ($request_method = 'OPTIONS') {
                      add_header 'Access-Control-Allow-Origin' 'https://antea.fetsorn.website';

                      add_header 'Access-Control-Allow-Credentials' 'true';
                      add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';

                      add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';

                      add_header 'Access-Control-Max-Age' 1728000;
                      add_header 'Content-Type' 'text/plain charset=UTF-8';
                      add_header 'Content-Length' 0;
                      return 204;
                   }
                   if ($request_method = 'POST') {
                      add_header 'Access-Control-Allow-Origin' 'https://antea.fetsorn.website';
                      add_header 'Access-Control-Allow-Credentials' 'true';
                      add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
                      add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
                   }
                   if ($request_method = 'GET') {
                      add_header 'Access-Control-Allow-Origin' 'https://antea.fetsorn.website';
                      add_header 'Access-Control-Allow-Credentials' 'true';
                      add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
                      add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
                  }
                '';
              };
            };

            networking = {
              usePredictableInterfaceNames = false;
              useDHCP = false;
              interfaces.eth0.useDHCP = true;
              firewall = {
                enable = true;
                allowedTCPPorts = [ 80 443 ];
              };
            };

            services.openssh = {
              enable = true;
              permitRootLogin = "no";
            };

            nix = {
              package = pkgs.nixUnstable;
              extraOptions = "experimental-features = nix-command flakes";
            };
            nixpkgs.config.allowUnfree = true;

            system = {
              configurationRevision = if self ? rev then
                self.rev
              else
                throw "Refusing to build from a dirty Git tree!";
              stateVersion = "21.11";
            };

            environment.systemPackages = with pkgs; [
              git
              ripgrep
              rsync
              vim
              wget
            ];

            users = {
              users.fetsorn = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
              };
              mutableUsers = true;
            };
          })
        ];
      }; # linode-gitea

      linode-stars = inputs.nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ({ pkgs, config, lib, modulesPath, ... }: {

            imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

            boot = {
              initrd = {
                availableKernelModules =
                  [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];
                kernelModules = [ ];
              };
              extraModulePackages = [ ];
              loader = {
                timeout = 10;
                grub = {
                  enable = true;
                  version = 2;
                  extraConfig = ''
                    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
                    terminal_input serial;
                    terminal_input serial
                  '';
                  forceInstall = true;
                  device = "nodev";
                };
              };
              kernelModules = [ ];
              kernelParams = [ "console=ttyS0,19200n8" ];
            };

            fileSystems."/" = {
              device = "/dev/sda";
              fsType = "ext4";
            };

            swapDevices = [{ device = "/dev/sdb"; }];

            security.acme = {
              acceptTerms = true;
              email = "anton@fetsorn.website";
            };

            systemd = let
              antea.f.w = "antea.fetsorn.website";
              antea.git =
                "git+https://source.fetsorn.website/fetsorn/antea#timeline-frontend";
              genea.f.w = "genea.fetsorn.website";
              genea.git =
                "git+https://source.fetsorn.website/fetsorn/genea?ref=fetsorn";
              mkService = webRoot: sourceUrl: {
                enable = true;
                description = webRoot;
                serviceConfig = { Type = "oneshot"; };
                startAt = "*:0/5";
                wantedBy = [ "multi-user.target" ];
                path = [ pkgs.nix pkgs.jq pkgs.git ];
                script = ''
                  set -ex

                  ln -sfT $(nix build --json --no-link --tarball-ttl 0 ${sourceUrl} | jq -r '.[0]."outputs"."out"') /var/www/${webRoot}
                '';
              };
            in {
              services.${antea.f.w} = mkService antea.f.w antea.git;
              services.${genea.f.w} = mkService genea.f.w genea.git;
            };

            services.nginx = {
              enable = true;
              recommendedGzipSettings = true;
              recommendedOptimisation = true;
              recommendedProxySettings = true;
              recommendedTlsSettings = true;
              virtualHosts."stars.fetsorn.website" = {
                enableACME = true;
                forceSSL = true;
                root = "/var/www/stars.fetsorn.website/antea";
                locations."~ ^/$".tryFiles = "/overview.html /index.html";
                locations."/".tryFiles = "$uri /index.html";
              };
              virtualHosts."antea.fetsorn.website" = {
                enableACME = true;
                forceSSL = true;
                locations."/".root = "/var/www/antea.fetsorn.website/";
                locations."/".tryFiles = "$uri /index.html";
              };
              virtualHosts."genea.fetsorn.website" = {
                enableACME = true;
                forceSSL = true;
                locations."/".root = "/var/www/genea.fetsorn.website/";
                locations."/".tryFiles = "$uri /index.html";
              };
            };

            networking = {
              usePredictableInterfaceNames = false;
              useDHCP = false;
              interfaces.eth0.useDHCP = true;
              firewall = {
                enable = true;
                allowedTCPPorts = [ 80 443 ];
              };
            };

            services.openssh = {
              enable = true;
              permitRootLogin = "no";
            };

            nix = {
              package = pkgs.nixUnstable;
              extraOptions = "experimental-features = nix-command flakes";
            };
            nixpkgs.config.allowUnfree = true;

            system = {
              configurationRevision = if self ? rev then
                self.rev
              else
                throw "Refusing to build from a dirty Git tree!";
              stateVersion = "21.11";
            };

            programs.git = {
              enable = true;
              config = {
                init = { defaultBranch = "main"; };
                pull = { rebase = false; };
                user = {
                  name = "Anton Davydov";
                  email = "fetsorn@gmail.com";
                };
              };
            };

            environment.systemPackages = with pkgs; [
              git
              ripgrep
              rsync
              vim
              wget
            ];

            users = {
              users.fetsorn = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
              };
              mutableUsers = true;
            };
          })
        ];
      }; # linode-stars

      sonicmaster = inputs.nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.home-manager.nixosModules.home-manager
          ({ pkgs, config, lib, modulesPath, ... }: {

            boot = {
              initrd = {
                availableKernelModules =
                  [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
                kernelModules = [ ];
              };
              kernelModules = [ "kvm-intel" ];
              extraModulePackages = [ ];
              loader = {
                systemd-boot.enable = true;
                efi.canTouchEfiVariables = true;
                grub.useOSProber = true;
              };
            };

            fileSystems = {
              "/" = {
                device =
                  "/dev/disk/by-uuid/52e503cb-0e91-40e7-9c94-2d4b9e60e6d2";
                fsType = "ext4";
              };

              "/boot" = {
                device = "/dev/disk/by-uuid/C6BD-7AE8";
                fsType = "vfat";
              };
            };

            swapDevices = [{
              device = "/dev/disk/by-uuid/2659bb64-6ca8-4b4a-b99f-524cf731021e";
            }];

            hardware = {
              cpu.intel.updateMicrocode =
                lib.mkDefault config.hardware.enableRedistributableFirmware;
              pulseaudio.enable = true;
            };

            powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

            nix = {
              package = pkgs.nixUnstable;
              extraOptions = "experimental-features = nix-command flakes";
              binaryCaches =
                [ "https://hydra.iohk.io" "https://iohk.cachix.org" ];
              binaryCachePublicKeys = [
                "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
                "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
              ];
              maxJobs = lib.mkDefault 4;
            };
            nixpkgs.config.allowUnfree = true;

            system = {
              configurationRevision = if self ? rev then
                self.rev
              else
                throw "Refusing to build from a dirty Git tree!";
              stateVersion = "21.11"; # Did you read the comment?
            };

            networking = {
              hostName = "sonicmaster"; # Define your hostname.
              wireless.enable =
                true; # Enables wireless support via wpa_supplicant.
              useDHCP = false;
              interfaces.wlp1s0.useDHCP = true;
            };

            i18n.defaultLocale = "en_US.UTF-8";
            console = {
              font = "Lat2-Terminus16";
              keyMap = "us";
            };

            time.timeZone = "Europe/Moscow";

            environment.systemPackages = with pkgs; [ git ];

            services = {
              openssh.enable = true;
              xserver = {
                enable = true;
                layout = "us,ru";
                xkbOptions = "ctrl:swapcaps,grp:alt_shift_toggle";
                libinput = {
                  enable = true;
                  mouse.leftHanded = true;
                };
                displayManager.defaultSession = "none+i3";
                windowManager = {
                  xmonad.enable = true;
                  i3 = {
                    enable = true;
                    extraPackages = with pkgs; [
                      dmenu
                      i3status
                      i3lock
                      i3blocks
                    ];
                    package = pkgs.i3-gaps;
                  };
                };
              };
            };

            sound.enable = true;

            users = {
              users = {
                fetsorn = {
                  isNormalUser = true;
                  extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
                };

                tapir = {
                  isNormalUser = true;
                  extraGroups = [ ];
                };
              };
            };

          })
        ];
      }; # sonicmaster
    }; # nixosConfigurations

    deploy.nodes.aws = {
      sshUser = "root";
      hostname = "34.219.138.142";
      sshOpts = [ "-i" "~/.ssh/nixos.pem" ];
      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos
          self.nixosConfigurations.aws-arm-simple;
      };
    };

    checks =
      builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy)
      inputs.deploy-rs.lib;

    apps.aarch64-linux.deployApp = {
      type = "app";
      program =
        "${inputs.deploy-rs.packages.aarch64-linux.deploy-rs}/bin/deploy";
    };
    defaultApp.aarch64-linux = self.apps.aarch64-linux.deployApp;

  }; # outputs
}
