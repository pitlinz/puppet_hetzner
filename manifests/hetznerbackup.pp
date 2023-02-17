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

    if $user and $passwd {
        pitlinz_hetzner::storage::backup{$mntpoint:
            user    => $user,
            passwd  => $passwd
        }
    } else {
        fail("user and/or passwd not set")
    }
}
