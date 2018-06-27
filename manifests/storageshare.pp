/**
 * class to mount a storage share
 * 
 * @author Peter Krebs <p.krebs@w4c.at>
 */
define pitlinz_hetzner::storageshare(
    $mntpoint 	= $name,
    $user 		= undef,
    $passwd 	= undef,
    $uid		= 0,
    $gid		= 0
) {

    if !defined(Package['cifs-utils']) {
        package{'cifs-utils':
            ensure => latest,
        }
    }

    if !defined(Exec["mkdir ${mntpoint}"]) {
        exec{"mkdir ${mntpoint}":
            command => "/bin/mkdir -p ${mntpoint}",
            creates => $mntpoint,
        }
    }

    file{$mntpoint:
        ensure 	=> directory,
        require	=> Exec["mkdir ${mntpoint}"]
    }

    if !defined(Mount[$mntpoint]) {
        $cifshare = "//${user}.your-storagebox.de/backup"

        if $uid != 0 {
            $_optuid= ",uid=${uid}"
        } else {
            $_optuid = ""
        }

        if $gid != 0 {
            $_optgid= ",gid=${gid}"
        } else {
            $_optgid = ""

        }

        mount{$mntpoint:
            ensure	=> mounted,
            device	=> $cifshare,
            fstype	=> "cifs",
            options => "noauto,rw,user,username=${user},password=${passwd}${_optuid}${_optgid}",
            atboot	=> false,
            require	=> [Exec["mkdir ${mntpoint}"],File[$mntpoint],Package['cifs-utils']]
        }
    }

}
