# Beyond Compare 5 Nix Flake

This is a Flake for using Beyond Compare 5 on NixOS or with Home Manager.

## Usage (Home Manager)

Add this repository to the `inputs` of your `flake.nix` and load the `homeManagerModules` to use it.

### 1. Configure `flake.nix`

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    # Add this repository
    bcompare5 = {
      url = "github:W4T4r/bcompare5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, bcompare5, ... }: {
    homeConfigurations."youruser" = home-manager.lib.homeManagerConfiguration {
      # Beyond Compare is unfree, so allowUnfree must be set
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = [
        ./home.nix
        # Add the module
        bcompare5.homeManagerModules.default
      ];
    };
  };
}
```

### 2. Enable in `home.nix`

After loading the module, install Beyond Compare by adding the following setting:

```nix
{
  programs.bcompare5.enable = true;
}
```

## Using Only the Package

It is also possible to use the package directly without the module.

```nix
{
  home.packages = [
    inputs.bcompare5.packages.x86_64-linux.default
  ];
}
```

## License

Beyond Compare is commercial software (unfree). A valid license is required for use.
This Flake does not include the binary itself. It provides only a recipe to download the official binary and apply patches.
