#!/bin/bash
#
disk_show=('/')
# Disk subtitle.
# What to append to the Disk subtitle.
#
# Default: 'mount'
# Values:  'mount', 'name', 'dir'
# Flag:    --disk_subtitle
#
# Example:
# name:   'Disk (/dev/sda1): 74G / 118G (66%)'
#         'Disk (/dev/sdb2): 74G / 118G (66%)'
#
# mount:  'Disk (/): 74G / 118G (66%)'
#         'Disk (/mnt/Local Disk): 74G / 118G (66%)'
#         'Disk (/mnt/Videos): 74G / 118G (66%)'
#
# dir:    'Disk (/): 74G / 118G (66%)'
#         'Disk (Local Disk): 74G / 118G (66%)'
#         'Disk (Videos): 74G / 118G (66%)'
disk_subtitle="mount"

get_disk() {
    type -p df &>/dev/null ||\
        { err "Disk requires 'df' to function. Install 'df' to get disk info."; return; }

    df_version="$(df --version 2>&1)"

    case "$df_version" in
        *"IMitv"*)   df_flags=(-P -g) ;; # AIX
        *"befhikm"*) df_flags=(-P -k) ;; # IRIX
        *"hiklnP"*) df_flags=(-h) ;; # OpenBSD

        *"Tracker"*) # Haiku
            err "Your version of df cannot be used due to the non-standard flags"
            return
        ;;

        *) df_flags=(-P -h) ;;
    esac

    # Create an array called 'disks' where each element is a separate line from
    # df's output. We then unset the first element which removes the column titles.
    IFS=$'\n' read -d "" -ra disks <<< "$(df "${df_flags[@]}" "${disk_show[@]:-/}")"
    unset "disks[0]"

    # Stop here if 'df' fails to print disk info.
    [[ -z "${disks[*]}" ]] && {
        err "Disk: df failed to print the disks, make sure the disk_show array is set properly."
        return
    }

    for disk in "${disks[@]}"; do
        # Create a second array and make each element split at whitespace this time.
        IFS=" " read -ra disk_info <<< "$disk"
        disk_perc="${disk_info[4]/\%}"

        case "$df_version" in
            *"befhikm"*)
                disk="$((disk_info[2]/1024/1024))G / $((disk_info[1]/1024/1024))G (${disk_perc}%)"
            ;;

            *)
                disk="${disk_info[2]/i} / ${disk_info[1]/i} (${disk_perc}%)"
            ;;
        esac

        # Subtitle.
        case "$disk_subtitle" in
            "name")
                disk_sub="${disk_info[0]}"
            ;;

            "dir")
                disk_sub="${disk_info[5]/*\/}"
                disk_sub="${disk_sub:-${disk_info[5]}}"
            ;;

            *)
                disk_sub="${disk_info[5]}"
            ;;
        esac

        # Bar.
        case "$disk_display" in
            "bar")     disk="$(bar "$disk_perc" "100")" ;;
            "infobar") disk+=" $(bar "$disk_perc" "100")" ;;
            "barinfo") disk="$(bar "$disk_perc" "100")${info_color} $disk" ;;
            "perc")    disk="${disk_perc}% $(bar "$disk_perc" "100")" ;;
        esac

        # Append '(disk mount point)' to the subtitle.
        if [[ -z "$subtitle" ]]; then
            prin "${disk_sub}" "$disk"
        else
            prin "${subtitle} (${disk_sub})" "$disk"
        fi
    done
}

echo $get_disk