# Beyond Compare 5 Nix Flake

Beyond Compare 5 を NixOS や Home Manager で利用するための Flake です。

## 使い方 (Home Manager)

ご自身の `flake.nix` の `inputs` にこのリポジトリを追加し、`homeManagerModules` を読み込むことで利用できます。

### 1. `flake.nix` の設定

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    # このリポジトリを追加
    bcompare5 = {
      url = "github:W4T4r/bcompare5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, bcompare5, ... }: {
    homeConfigurations."youruser" = home-manager.lib.homeManagerConfiguration {
      # Beyond Compare は Unfree なので許可設定が必要
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = [
        ./home.nix
        # モジュールを追加
        bcompare5.homeManagerModules.default
      ];
    };
  };
}
```

### 2. `home.nix` での有効化

モジュールを読み込んだら、以下の設定を追加するだけでインストールされます。

```nix
{
  programs.bcompare5.enable = true;
}
```

## パッケージのみを利用する場合

モジュールを使わず、直接パッケージを参照することも可能です。

```nix
{
  home.packages = [
    inputs.bcompare5.packages.x86_64-linux.default
  ];
}
```

## ライセンス

Beyond Compare は商用ソフトウェア（Unfree）です。利用にはライセンスが必要です。
この Flake は本体のバイナリを含まず、公式サイトからダウンロードしてパッチを当てるためのレシピのみを提供します。
