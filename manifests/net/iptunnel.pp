# defines an ip tunnel to a remote host
#
define pitlinz_hetzner::net::iptunnel(
    $ensure     = present,
    $ifname     = $name,

    $remoteip   = undef,
    $rnetwork   = undef,
    $rnetmask   = '255.255.255.0',

    $localip    = $::ipaddress,
    $lnetwork   = $::network_virbr0,
    $lnetmask   = $::netmask_virbr0,

    $tnetpre    = undef
) {

    if !validate_ip_address($remoteip) {
        fail("remote address: $remoteip is not a valid ip address")
    }

    if !validate_ip_address($rnetwork) {
        fail("remote net: $rnetwork is not a valid ip address")
    }

    if !validate_ip_address($lnetwork) {
        fail("remote net: $lnetwork is not a valid ip address")
    }

    if $remoteip == $localip {
        fail("same host")
    }

    if !defined(File["/etc/firewall"]) {
		file{"/etc/firewall":
		    ensure => directory
		}
	}

    $arr_rip   = split($remoteip,'[.]')
    $arr_rnet  = split($rnetwork,'[.]')
    $arr_lip   = split($localip,'[.]')
    $arr_lnet  = split($lnetwork,'[.]')

    if $tnetpre {
        $tnetwork   = "${tnetpre}.0"
        if $remoteip > $localip {
            $tlocalip   = "${tnetpre}.1"
            $tremoteip  = "${tnetpre}.2"
    	} else {
            $tlocalip   = "${tnetpre}.2"
            $tremoteip  = "${tnetpre}.1"
    	}
    } else {
    	if $remoteip > $localip {
            $ida = $arr_lnet[2]
            $idb = $arr_rnet[2]
            $tlocalip   = "10.${ida}.${$idb}.2"
            $tremoteip  = "10.${ida}.${$idb}.1"
    	} else {
            $ida = $arr_rnet[2]
            $idb = $arr_lnet[2]
            $tremoteip  = "10.${ida}.${$idb}.2"
            $tlocalip   = "10.${ida}.${$idb}.1"
        }

        $tnetwork   = "10.${ida}.${$idb}.0"
    }

    file{"/etc/firewall/050-iptunnel-${name}.sh":
        content => template('pitlinz_hetzner/net/iptunnel.erb'),
        mode    => '0550',
        notify  => Exec["iptunnel_${name}_restart"]
    }

    exec{"iptunnel_${name}_restart":
        command     => "/etc/firewall/050-iptunnel-${name}.sh restart",
        require     => File["/etc/firewall/050-iptunnel-${name}.sh"],
        refreshonly => true
    }

}
