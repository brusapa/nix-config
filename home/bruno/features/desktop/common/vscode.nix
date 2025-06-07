{ lib, pkgs, ... }:

{

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default = {
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        # General
        mkhl.direnv
        gruntfuggly.todo-tree
        github.copilot
        github.copilot-chat
        yzhang.markdown-all-in-one
        # Better configuration files support
        tamasfe.even-better-toml
        redhat.vscode-xml
        redhat.vscode-yaml
        # C/C++
        ms-vscode.cpptools-extension-pack
        twxs.cmake
        # C#
        ms-dotnettools.csdevkit
        ms-dotnettools.csharp
        ms-dotnettools.vscodeintellicode-csharp
        # Nix
        jnoortheen.nix-ide
        # PlantUML
        jebbs.plantuml
        # Python
        ms-python.python
        ms-python.vscode-pylance
        ms-python.pylint
        ms-python.debugpy
        # Rust
        rust-lang.rust-analyzer
        # Remote development extensions
        ms-vscode-remote.remote-ssh
      ];
      userSettings = {
        "workbench.colorTheme" = "Default Light Modern";
        "workbench.startupEditor" = "none";
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Droid Sans Mono', 'monospace'";
        "editor.renderWhitespace" = "all";
        "editor.minimap.enabled" = false;
        "telemetry.feedback.enabled" = false;
        "telemetry.telemetryLevel" = "off";
      };
    };
  };
}
