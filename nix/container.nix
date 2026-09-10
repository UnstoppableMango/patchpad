{
  nix2container,
  patchpad,
}:
nix2container.buildImage {
  name = "patchpad";
  config = {
    Cmd = [ "${patchpad}/bin/patchpad" ];
  };
}
