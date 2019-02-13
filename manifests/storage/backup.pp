/**
 * creates a backup share
 *
 * @author Peter Krebs <p.krebs@w4c.at>
 */
define pitlinz_hetzner::storage::backup(
    $mntpoint   = $name,
    $user       = '',
    $passwd     = '',
    $mode	    = '0755'
) {

    if !$user or !$passwd {
        fail("user and/or passwd not set")
    }

    if !defined(Package['cifs-utils']) {
        package{'cifs-utils':
            ensure => latest,
        }
    }

    if !defined(Exec["mkdir ${mntpoint}"]) {
        exec{"mkdir ${mntpoint}":
            command 	=> "/bin/mkdir -p ${mntpoint}",
            creates		=> $mntpoint,
        }
    }

    file{$mntpoint:
        ensure 	=> directory,
        mode   	=> $mode,
        require	=> Exec["mkdir ${mntpoint}"]
    }

    if !defined(Mount["${mntpoint}"]) {
        $cifshare = "//${user}.your-backup.de/backup"

        mount{$mntpoint:
            ensure	=> mounted,
            device	=> $cifshare,
            fstype	=> "cifs",
            options => "noauto,rw,user,username=${user},password=${passwd}",
            atboot	=> false,
            require	=> [Exec["mkdir ${mntpoint}"],File["${mntpoint}"],Package['cifs-utils']]
        }
    }

}
