 
#Programable completion for nordicbetsite under bash

_nordicbetsite()
{
    firstArg="--nodaemon --debug --nofork --prefix --log_config_file --db_user_pwd --db_user --db_dbname --db_host --db_port --spew --version --help -n -b -l -P -u -D -h -N initdocs configdocs cidocs stop updatedocs start ftest initdb test tabbash restart "

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=( $( compgen -W "$firstArg" -- $cur) )
        return 0
    fi
    if [[ ${COMP_WORDS[1]} -eq "nordicbetsite" && $COMP_CWORD -eq 2 ]]; then
        cmdOpt1=
        case ${COMP_WORDS[1]} in
        initdocs)
            cmdOpt1="--version --help "
            ;;
        configdocs|i)
            cmdOpt1="--database --data --updates --version --help -f -d -d "
            ;;
        cidocs)
            cmdOpt1="--version --help "
            ;;
        start|b|restart|r|stop|s)
        cmdOpt1="all application_server presentation_server back_office_server batch_server docs_server livebet_bo livebet_fo xml_server import_fixture_server --run_what_server --pid_file_app --pid_file_pr --pid_file_bo --pid_file_bat --pid_file_stats --pid_file_docs --pid_file_mgs --pid_file_wap --pid_file --run_what_server --pid_file_app --pid_file_pr --pid_file_bo --pid_file_bat --pid_file_stats --pid_file_docs --pid_file_mgs --pid_file_wap --pid_file --version --help -w -w "
            ;;
        updatedocs|i)
            cmdOpt1="--database --data --updates --version --help -f -d -d "
            ;;
        ftest|f)
            cmdOpt1="--keep_db --no_reset_db --test_pattern --test_dir --test_pattern --ftest_verbosity --version --help -P -D -P -v "
            ;;
        initdb|i)
            cmdOpt1="--database --data --updates --version --help -f -d -d "
            ;;
        test|t)
            cmdOpt1="--test_pattern --test_dir --version --help -P -D "
            ;;
        tabbash)
            cmdOpt1="--version --help "
            ;;
        esac
        COMPREPLY=( $( compgen -W "$cmdOpt1" -- $cur ) )
        return 0
    fi


}

_startNor()
{
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    cmdOpt1="all application_server presentation_server back_office_server batch_server docs_server livebet_bo livebet_fo xml_server import_fixture_server --run_what_server --pid_file_app --pid_file_pr --pid_file_bo --pid_file_bat --pid_file_stats --pid_file_docs --pid_file_mgs --pid_file_wap --pid_file --run_what_server --pid_file_app --pid_file_pr --pid_file_bo --pid_file_bat --pid_file_stats --pid_file_docs --pid_file_mgs --pid_file_wap --pid_file --version --help -w -w "
    COMPREPLY=( $( compgen -W "$cmdOpt1" -- $cur ) )
    return 0
}
complete -F _nordicbetsite -o default nordicbetsite
complete -F _startNor -o default startNor

