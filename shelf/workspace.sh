##############################################################
# workspace.sh
# Quickly create/search/switch-to project directories. Run
# with any term to search existing workspaces (or to switch to
# that workspace if only one is matched.) Use -d to sort by
# timestamp or -c to create a new workspace.
##############################################################

function workspace() {
    local WORKSPACE_ROOT=~/workspaces
    local ACTION=""
    local ORDER="name"
    local LABEL=""
    case $1 in
        -c|--create)
            ACTION="create"
            LABEL="$2"
            ;;
        -h|--help)
            ACTION="help"
            ;;
        -d|--date)
            ORDER="date"
            ACTION="goto"
            LABEL="$2"
            ;;
        *)
            ACTION="goto"
            LABEL="$1"
            ;;
    esac
    case $ACTION in
        help)
            echo "Usage: workspace [OPTIONS] <LABEL>"
            echo "Switch to a workspace with the given label. Or, if an option is given:"
            echo
            echo "  -c, --create     Create a workspace with the given label."
            echo "  -h, --help       Display this help message."
			echo
			echo "If no argument is given, switch to the latest workspace."
            return 0
        ;;
        create)
            if [ -z "$LABEL" ]; then
                >&2 echo "Provide a label to create a workspace."
                return 1
            fi
            local TIMESTAMP="$(date '+%y%m%d')"
            local WORKSPACE_PATH="$WORKSPACE_ROOT/$LABEL.$TIMESTAMP"
            if [ -e "$WORKSPACE_PATH" ]; then
                >&2 echo "Workspace already exists at $WORKSPACE_PATH"
                return 1
            fi
            >&2 mkdir -p "$WORKSPACE_PATH"
            >&2 echo "Leaving $PWD"
            cd "$WORKSPACE_PATH"
            return $?
        ;;
        *)
            if [ -z "$LABEL" ]; then
                >&2 echo "Leaving $PWD"
                cd $(ls -td ~/workspaces/*|head -n1)
                return 1
            fi
            local WORKSPACES=$(ls -td $WORKSPACE_ROOT/*|awk -F/ '{print $NF}')
            if [ "$ORDER" = "date" ]; then
                local WORKSPACE_LIST=$(awk -F. '{print $2,$0}'<<<$WORKSPACES|sort -n|awk '{print $2}')
            else
                local WORKSPACE_LIST=$(sort<<<$WORKSPACES)
            fi
            if ! grep -q $LABEL <<< $WORKSPACE_LIST; then
                >&2 echo "Found 0 workspaces matching \"$LABEL\""
                return 1
            else
                local MATCHES=$(grep --color $LABEL <<< $WORKSPACE_LIST)
                if [ $(wc -l <<< $MATCHES|xargs) -eq 1 ]; then
                    >&2 echo "Leaving $PWD"
                    cd "$WORKSPACE_ROOT/$MATCHES"
                else
                    >&2 echo "Found $(wc -l <<< $MATCHES|xargs) matching workspaces:"
                    sed 's/^/  /' <<< $MATCHES|grep --color $LABEL
                    return 1
                fi
            fi
            return $?
        ;;
    esac
}
