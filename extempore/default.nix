# https://github.com/andreykaipov/home/blob/master/.config/nixpkgs/cli/extempore/
{ stdenv, fetchFromGitHub, cmake, gnumake, python3, gcc, darwin }:

stdenv.mkDerivation rec {
  pname = "extempore";
  version = "010ae8fa46fd66f020c7e379b7e0429d050a16c0";

  src = fetchFromGitHub {
    owner = "digego";
    repo = pname;
    rev = version;
    sha256 = "sha256-Jwbwh8UFvRqn2s+vGWbNquU6CchQQ5sYdHRRvNR89NM=";
  };

  patches = [ ./cmakelists.txt.patch ];

  nativeBuildInputs = [
    cmake
    python3
    gcc
    gnumake
    # extempore explicitly asks for the following
    #include <Cocoa/Cocoa.h>
    #include <CoreFoundation/CoreFoundation.h>
    #include <AppKit/AppKit.h>
    #
    # initially build errored asking for AudioUnit, Carbon, CoreAudio and more
    #
    # darwin.apple_sdk.framework.Cocoa includes it all
    # Cocoa                   = { inherit AppKit CoreData; };
    # Carbon                  = { inherit libobjc ApplicationServices CoreServices Foundation IOKit Security QuartzCore; };
    # AppKit                  = { inherit ApplicationServices AudioToolbox AudioUnit Foundation QuartzCore UIFoundation; };
    # ApplicationServices     = { inherit CoreGraphics CoreServices CoreText ImageIO; };
    # CoreServices            = { inherit CFNetwork CoreFoundation CoreAudio CoreData DiskArbitration Security NetFS OpenDirectory ServiceManagement; };
    # AudioUnit               = { inherit AudioToolbox Carbon CoreAudio; };
    # AudioToolbox            = { inherit CoreAudio CoreMIDI; };
    # CoreAudio               = { inherit IOKit; };
    darwin.apple_sdk.frameworks.Cocoa
  ];

  # cmakeFlags = [ "-DASSETS=ON" ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    mv $pname "$out/bin"
  '';
}
