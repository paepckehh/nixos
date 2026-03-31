boot.kernelParams = [ "zfs.zfs_arc_max="51539607552" ]; # 48GB
nix-shell -p openseachest
sudo openSeaChest_Format -d /dev/sda --formatUnit 4096 --fastFormat 1 --poll --confirm this-will-erase-data-and-may-render-the-drive-inoperable
