{pkgs, ...}: with pkgs;
{
    jetbrainsPackages = [
        jetbrains.clion
        jetbrains.rider
        jetbrains.rust-rover
        jetbrains.dataspell
        jetbrains.idea
        jetbrains.datagrip
    ];
}
