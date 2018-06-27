/*
 * class to mount hetzner backup share
 * 
 * @author Peter Krebs <p.krebs@w4c.at>
 * 
 */
class pitlinz_hetzner::hetznerbackup(
    $mntpoint   = '/var/hetznerbackup',
    $user       = undef,
    $passwd     = undef
) {
    pitlinz_hetzner::backupshare{$mntpoint:
        user    => $user,
        passwd  => $passwd
    }
}
