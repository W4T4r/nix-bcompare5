{
  description = "Beyond Compare 5 Flake for Home Manager and NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
      homeManagerModule = { config, lib, pkgs, ... }:
        let
          cfg = config.programs.bcompare5;
        in
        {
          options.programs.bcompare5 = {
            enable = lib.mkEnableOption "Beyond Compare 5";
            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.bcompare5;
              description = "The bcompare5 package to use.";
            };
          };

          config = lib.mkIf cfg.enable {
            home.packages = [ cfg.package ];
          };
        };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        rec {
          bcompare5 = pkgs.stdenv.mkDerivation rec {
            pname = "bcompare5";
            version = "5.2.1.32035";

            src = pkgs.fetchurl {
              url = "https://www.scootersoftware.com/files/bcompare-${version}.x86_64.tar.gz";
              sha256 = "121in8dmlljgbfa604v4im616yk9i0gsvahcds97n651kpxnkzq4";
            };

            nativeBuildInputs = [
              pkgs.autoPatchelfHook
            ];

            buildInputs = [
              pkgs.stdenv.cc.cc.lib
              pkgs.libX11
              pkgs.libXext
              pkgs.libXrender
              pkgs.libice
              pkgs.libsm
              pkgs.dbus
              pkgs.zlib
              pkgs.bzip2
              pkgs.fontconfig
              pkgs.freetype
              pkgs.libxcrypt-legacy
              pkgs.qt6.qtbase
            ];

            dontWrapQtApps = true;

            autoPatchelfIgnoreMissingDeps = [
              "libKF6KIOWidgets.so.6"
              "libKF6KIOGui.so.6"
              "libKF6KIOCore.so.6"
              "libKF6I18n.so.6"
              "libKF6CoreAddons.so.6"
              "libKF5KIOWidgets.so.5"
              "libKF5KIOGui.so.5"
              "libKF5KIOCore.so.5"
              "libKF5I18n.so.5"
              "libKF5CoreAddons.so.5"
              "libQt5Widgets.so.5"
              "libQt5Gui.so.5"
              "libQt5Core.so.5"
              "libkio.so.5"
              "libQtGui.so.4"
              "libkdecore.so.5"
              "libQtCore.so.4"
            ];

            installPhase = ''
              runHook preInstall

              mkdir -p \
                $out/bin \
                $out/lib/bcompare \
                $out/share/applications \
                $out/share/mime/packages \
                $out/share/pixmaps

              cp -r * $out/lib/bcompare/

              install -m 755 bcompare.sh $out/bin/bcompare
              substituteInPlace $out/bin/bcompare \
                --replace-fail "BC_LIB=" "BC_LIB=$out/lib/bcompare" \
                --replace-fail "BC_PACKAGE_TYPE=" "BC_PACKAGE_TYPE=archive" \
                --replace-fail "/bin/bash" "${pkgs.bash}/bin/bash"

              patchShebangs $out/bin $out/lib/bcompare

              if [ -f bcompare.desktop ]; then
                cp bcompare.desktop $out/share/applications/
                substituteInPlace $out/share/applications/bcompare.desktop \
                  --replace-fail "Exec=bcompare %f" "Exec=$out/bin/bcompare %f" \
                  --replace-fail "TryExec=bcompare" "TryExec=$out/bin/bcompare"
              fi

              if [ -f bcompare.xml ]; then
                cp bcompare.xml $out/share/mime/packages/
              fi

              cp bcompare.png $out/share/pixmaps/

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Beyond Compare 5 - Powerful File and Folder Comparison";
              homepage = "https://www.scootersoftware.com/";
              license = licenses.unfree;
              mainProgram = "bcompare";
              platforms = supportedSystems;
              sourceProvenance = with sourceTypes; [ binaryNativeCode ];
            };
          };

          default = bcompare5;
        }
      );

      apps = forAllSystems (system:
        rec {
          bcompare5 = {
            type = "app";
            program = "${self.packages.${system}.bcompare5}/bin/bcompare";
          };
          default = bcompare5;
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.nixfmt-rfc-style ];
          };
        }
      );

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);

      homeManagerModules = {
        default = homeManagerModule;
        bcompare5 = homeManagerModule;
      };
    };
}
