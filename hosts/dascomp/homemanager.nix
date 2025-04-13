{pkgs, ... }: {
  imports = [
    ../../modules/homemanager/gui
  ];
	home.packages = with pkgs;[
	ollama-rocm
	];
}
