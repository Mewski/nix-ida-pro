# Nix flake for IDA Pro
This is an unofficial Nix flake for running IDA Pro on NixOS.

## Usage

### NixOS module

To include IDA Pro in your NixOS system using this flake, follow these steps:

 1. **Add this flake to your NixOS configuration flake's inputs:**

    ```nix
    {
      inputs = {
        nixpkgs = { ... };

        ida-pro = {
          url = "github:mewski/nix-ida-pro";

          # Optional, but recommended.
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    ```

 2. **Include the NixOS module in your NixOS system:**

    ```nix
    {
      ...
      outputs = { nixpkgs, ida-pro, ... }:
      {
        nixosConfigurations.myMachine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ...
            ida-pro.nixosModules.ida-pro
          ];
        };
      };
    }
    ```

 3. **Enable IDA Pro in your NixOS configuration:**

    ```nix
    {
      programs.ida-pro.enable = true;
    }
    ```

    If you want to use the Wayland variant, you can select it using `programs.ida-pro.package`:

    ```nix
    { pkgs, ... }: {
      programs.ida-pro = {
        enable = true;
        package = pkgs.ida-pro-wayland;
      };
    }
    ```

 4. **Add the installer to the nix store:**

    ```console
    $ nix-store --add-fixed sha256 ida-pro_93_x64linux.run
    ```

    You can download the installer from the [Hex-Rays download center](https://my.hex-rays.com/).

    If you want, it is possible to include a copy of the installer in your NixOS configuration to avoid this step.
    If you choose to do this, please be mindful to not accidentally leak your copy of IDA Pro.

    To do this, you need to override the IDA Pro package, like this:

    ```nix
    { pkgs, ... }: {
      programs.ida-pro = {
        enable = true;
        package = pkgs.ida-pro.override {
          overrideSource = ./ida-pro_93_x64linux.run;
        };
      };
    }
    ```

### Home Manager module

A Home Manager module is also available:

```nix
{
  imports = [ ida-pro.hmModules.ida-pro ];

  programs.ida-pro.enable = true;
}
```

## Packages

The following package attributes are available:

- `ida-pro`
- `ida-pro-wayland`

Note that you will need to provide the installer from the [Hex-Rays download center](https://my.hex-rays.com/).

The `-wayland` variant will force IDA Pro to use the Wayland window system.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
