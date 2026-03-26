# Beyond Compare 5 Nix Flake

A small Nix flake that packages the official Beyond Compare 5 Linux tarball and
exposes a Home Manager module.

## Supported Systems

- `x86_64-linux`

## What This Flake Exposes

- `packages.x86_64-linux.bcompare5`
- `packages.x86_64-linux.default`
- `apps.x86_64-linux.default`
- `homeManagerModules.default`
- `homeManagerModules.bcompare5`

## Usage

### Run directly

```bash
nix run github:W4T4r/bcompare5
```

### Use only the package

```nix
{
  home.packages = [
    inputs.bcompare5.packages.${pkgs.system}.default
  ];
}
```

### Use with Home Manager

Add this repository to the `inputs` of your `flake.nix` and load the module:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    bcompare5 = {
      url = "github:W4T4r/bcompare5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, bcompare5, ... }: {
    homeConfigurations."youruser" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      modules = [
        ./home.nix
        bcompare5.homeManagerModules.default
      ];
    };
  };
}
```

Then enable it in `home.nix`:

```nix
{
  programs.bcompare5.enable = true;
}
```

If needed, you can override the package used by the module:

```nix
{
  programs.bcompare5 = {
    enable = true;
    package = inputs.bcompare5.packages.${pkgs.system}.bcompare5;
  };
}
```

## Development

```bash
nix fmt
nix build .#bcompare5
```

`nix develop` provides `nixfmt-rfc-style` for local formatting.

## Licensing

The repository contents are licensed under MIT. See `LICENSE`.

Beyond Compare itself is commercial software and remains unfree. A valid
license is required for continued use. This flake does not redistribute the
application source code; it fetches the official binary release from Scooter
Software.
