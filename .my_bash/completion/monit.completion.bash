_monit()
{
    firstArg="start stop restart monitor unmonitor status summary reload quit validate"
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=( $( compgen -W "$firstArg" -- $cur) )
        return 0
    fi

    if [[ ${COMP_WORDS[1]} -eq "monit" && $COMP_CWORD -eq 2 ]]; then
        cmdOpt1=
        case ${COMP_WORDS[1]} in
          start|stop|restart|monitor|unmonitor)
            processes=$(monit summary | perl -ne "print \$1 . ' '  if /^Process '(\w+)'/")
            cmdOpt1="all $processes"
            ;;
          status|summary|reload|quit|validate)
            cmdOpt1=""
            ;;
        esac
        COMPREPLY=( $( compgen -W "$cmdOpt1" -- $cur ) )
        return 0
    fi
}
complete -F _monit -o default monit

