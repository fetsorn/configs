{
  description = "NixOS configuration";

  inputs = {
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = { nixpkgs.follows = "nixpkgs-unstable"; };
    };
    evenor = {
      url = "git+https://source.qualifiedself.org/fetsorn/evenor?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    morio = {
      url = "git+https://source.qualifiedself.org/fetsorn/morio?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    genea = {
      url = "git+https://source.qualifiedself.org/fetsorn/genea?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    elmsd = {
      url =
        "git+https://source.qualifiedself.org/fetsorn/elm-system-dynamics?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    arcoiris = {
      url =
        "git+https://source.qualifiedself.org/fetsorn/arcoiris-demo?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    kasner = {
      url = "github:fetsorn/kasner-demo?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    quiz = {
      url = "github:fetsorn/quiz-demo?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs@{ self, ... }: {
    homeConfigurations = {
      darwin = inputs.home-manager.lib.homeManagerConfiguration rec {
        pkgs = inputs.nixpkgs-unstable.legacyPackages."aarch64-darwin";
        modules = [
          (let
            pkgs-x86_64 = import inputs.nixpkgs-unstable {
              system = "x86_64-darwin";
              overlays = [ inputs.rust-overlay.overlays.default ];
            };
            pkgs-aarch64 = import inputs.nixpkgs-unstable {
              system = "aarch64-darwin";
              overlays = [ inputs.rust-overlay.overlays.default ];
            };
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
          in {
            nix = {
              package = pkgs.nixUnstable;
              settings = {
                experimental-features = [ "nix-command" "flakes" ];
                trusted-substituters = [
                  "https://cache.nixos.org"
                  "https://nrdxp.cachix.org"
                  "https://digitallyinduced.cachix.org"
                ];
                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                  "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4="
                  "digitallyinduced.cachix.org-1:y+wQvrnxQ+PdEsCt91rmvv39qRCYzEgGQaldK26hCKE="
                ];
              };
            };

            home = {
              homeDirectory = "/Users/fetsorn";
              username = "fetsorn";
              stateVersion = "22.11";
              activation = {
                myActivationAction = inputs.home-manager.lib.hm.dag.entryAfter
                  [ "writeBoundary" ] ''
                    $DRY_RUN_CMD [ ! -e $HOME/.local/share/password-store ] && \
                        ln -s $VERBOSE_ARG \
                        $HOME/mm/modes/secrets/password-store/ \
                        $HOME/.local/share/password-store
                  '';
              };
              file = {
                ".p10k.zsh".source = ./dotfiles/p10k.zsh;
                ".doom.d/init.el".source = ./dotfiles/doom-init.el;
                ".doom.d/config.el".source = ./dotfiles/doom-config.el;
                ".doom.d/packages.el".source = ./dotfiles/doom-packages.el;
                ".hammerspoon/init.lua".source = ./dotfiles/init.lua;
                ".hammerspoon/loopstop.lua".source = ./dotfiles/loopstop.lua;
                ".pijulconfig".source = ./dotfiles/pijulconfig;
              };

              packages = with pkgs; [
                ((emacsPackagesFor emacs).emacsWithPackages
                  (epkgs: [ epkgs.vterm ]))
                coreutils
                git-lfs
                nixfmt
                nixUnstable
                noisegen
                ripgrep
                rsync
                tmux
                tree
                wget
                zsh-powerlevel10k
                #(pkgs.texlive.combine {
                #  inherit (pkgs.texlive) scheme-small dvipng latexmk;
                #})
                #swiProlog
                #coq
                #ihp-new
                #direnv
                #cachix
                # pkgs-x86_64.cargo
                # pkgs-aarch64.rust-bin.nightly.latest.default
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
                userName = "fetsorn";
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
                initExtraFirst = ''
                  source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
                  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
                '';
                initExtra = builtins.readFile ./dotfiles/zshrc;
              };

            }; # programs
          }) # configuration
        ]; # modules
      }; # darwin

      linux = inputs.home-manager.lib.homeManagerConfiguration {
        stateVersion = "23.11";
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
              ((emacsPackagesFor emacs).emacsWithPackages
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
              userName = "fetsorn";
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
      linode = inputs.nixos-unstable.lib.nixosSystem {
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
              defaults.email = "fetsorn@gmail.com";
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
              dump = { # /var/lib/gitea/dump
                enable = true;
                interval = "monthly";
              };
              settings = {
                repository = { DEFAULT_BRANCH = "main"; };
                server = {
                  ROOT_URL = "https://source.qualifiedself.org/";
                  HTTP_PORT = 3001;
                  DOMAIN = "source.qualifiedself.org";
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
              ensureDatabases = [ "nextcloud" ];
              ensureUsers = [{
                name = "nextcloud";
                ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
              }];
            };

            services.nginx = {
              enable = true;
              recommendedGzipSettings = true;
              recommendedOptimisation = true;
              recommendedProxySettings = true;
              recommendedTlsSettings = true;
              clientMaxBodySize = "100m";
              commonHttpConfig = ''
                map $http_origin $allow_origin {
                    ~^https?://(.*\.)?(qualifiedself.org)(:\d+)?(/?)$ $http_origin;
                    default "";
                }
              '';
              virtualHosts."source.qualifiedself.org" = {
                enableACME = true;
                forceSSL = true;
                locations."/".proxyPass = "http://localhost:3001/";
                locations."/".extraConfig = ''
                  if ($request_method = 'OPTIONS') {
                     add_header 'Access-Control-Allow-Origin' $allow_origin always;
                     add_header 'Access-Control-Allow-Credentials' 'true' always;
                     add_header 'Access-Control-Allow-Methods' 'GET,HEAD,POST,PUT,PATCH,DELETE,OPTIONS' always;
                     add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization,x-authorization' always;
                     add_header 'Access-Control-Expose-Headers' 'Authorization' always;
                     return 204;
                  }
                  if ($request_method = 'POST') {
                     add_header 'Access-Control-Allow-Origin' $allow_origin always;
                     add_header 'Access-Control-Allow-Credentials' 'true' always;
                     add_header 'Access-Control-Allow-Methods' 'GET,HEAD,POST,PUT,PATCH,DELETE,OPTIONS' always;
                     add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization,x-authorization' always;
                     add_header 'Access-Control-Expose-Headers' 'Authorization' always;
                  }
                  if ($request_method = 'GET') {
                     add_header 'Access-Control-Allow-Origin' $allow_origin always;
                     add_header 'Access-Control-Allow-Credentials' 'true' always;
                     add_header 'Access-Control-Allow-Methods' 'GET,HEAD,POST,PUT,PATCH,DELETE,OPTIONS' always;
                     add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization,x-authorization' always;
                     add_header 'Access-Control-Expose-Headers' 'Authorization' always;
                  }
                '';
              };
              virtualHosts."qua.qualifiedself.org" = {
                enableACME = true;
                forceSSL = true;
                locations."/".extraConfig = ''
                  proxy_hide_header Upgrade;
                '';
                root = inputs.evenor.packages.${pkgs.system}.webapp;
                locations."~ ^/$".tryFiles = "/overview.html /index.html";
                locations."/".tryFiles = "$uri /index.html";
              };
              virtualHosts."arcoiris.qualifiedself.org" = {
                enableACME = true;
                forceSSL = true;
                locations."/".extraConfig = ''
                  proxy_hide_header Upgrade;
                '';
                root = inputs.arcoiris.packages.${pkgs.system}.webapp;
                locations."~ ^/$".tryFiles = "/overview.html /index.html";
                locations."/".tryFiles = "$uri /index.html";
              };
              virtualHosts."quiz.qualifiedself.org" = {
                enableACME = true;
                forceSSL = true;
                locations."/".extraConfig = ''
                  proxy_hide_header Upgrade;
                '';
                root = inputs.quiz.packages.${pkgs.system}.webapp;
                locations."~ ^/$".tryFiles = "/overview.html /index.html";
                locations."/".tryFiles = "$uri /index.html";
              };
              virtualHosts."kasner.qualifiedself.org" = {
                enableACME = true;
                forceSSL = true;
                locations."/".extraConfig = ''
                  proxy_hide_header Upgrade;
                '';
                root = inputs.kasner.packages.${pkgs.system}.webapp;
                locations."~ ^/$".tryFiles = "/overview.html /index.html";
                locations."/".tryFiles = "$uri /index.html";
              };
              virtualHosts."morio.qualifiedself.org" = {
                enableACME = true;
                forceSSL = true;
                locations."/".extraConfig = ''
                  proxy_hide_header Upgrade;
                '';
                root = inputs.morio.packages.${pkgs.system}.webapp.override {
                  defaultURL =
                    "https://source.qualifiedself.org/fetsorn/antiphongordon";
                };
                locations."~ ^/$".tryFiles = "/overview.html /index.html";
                locations."/".tryFiles = "$uri /index.html";
              };
              virtualHosts."sd.qualifiedself.org" = {
                enableACME = true;
                forceSSL = true;
                locations."/".extraConfig = ''
                  proxy_hide_header Upgrade;
                '';
                root = inputs.elmsd.packages.${pkgs.system}.default;
                locations."/".tryFiles = "$uri /Main.html";
              };
              virtualHosts."genea.qualifiedself.org" = {
                enableACME = true;
                forceSSL = true;
                locations."/".extraConfig = ''
                  proxy_hide_header Upgrade;
                '';
                root = inputs.genea.packages.${pkgs.system}.genea;
                locations."/".tryFiles = "$uri /index.html";
              };
              virtualHosts."static.qualifiedself.org" = {
                enableACME = true;
                forceSSL = true;
                locations."/".extraConfig = ''
                  proxy_hide_header Upgrade;
                  autoindex on;
                '';
                root = "/var/www/static.qualifiedself.org";
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

            # systemd.services."nextcloud-setup" = {
            #   requires = [ "postgresql.service" ];
            #   after = [ "postgresql.service" ];
            # };

            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "no";
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
              stateVersion = "23.11";
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
      }; # linode
    }; # nixosConfigurations
  }; # outputs
}
