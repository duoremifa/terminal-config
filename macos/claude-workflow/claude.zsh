# claude.zsh - Claude Code 项目管理快捷命令 (macOS 版)
# 项目根路径通过环境变量 CLAUDE_PROJECT_ROOT 配置
# 没设环境变量时默认 $HOME/Projects

export CLAUDE_PROJECT_ROOT=${CLAUDE_PROJECT_ROOT:-"$HOME/Projects"}

# pl - 列出所有项目
function pl() {
    if [[ ! -d "$CLAUDE_PROJECT_ROOT" ]]; then
        echo -e "\033[33m  项目根目录不存在: $CLAUDE_PROJECT_ROOT\033[0m"
        return
    fi
    echo -e "\n\033[36m  项目列表：\033[0m"
    ls -ltF "$CLAUDE_PROJECT_ROOT" | grep '^d' | awk '{print "    " $9 " \t" $6 " " $7 " " $8}' | sed 's/\/$//'
    echo ""
}

# pj - 进入项目并启动 claude
function pj() {
    local project=$1
    local projects_dir="$CLAUDE_PROJECT_ROOT"

    if [[ ! -d "$projects_dir" ]]; then
        mkdir -p "$projects_dir"
    fi

    if [[ -z "$project" ]]; then
        echo -e "\n\033[36m  项目列表（按最近更新排序）：\033[0m"
        # 获取所有非隐藏目录并按修改时间倒序排列
        local dirs=($(ls -t "$projects_dir" | grep -v '^\.' | while read -r line; do [[ -d "$projects_dir/$line" ]] && echo "$line"; done))
        
        if [[ ${#dirs[@]} -eq 0 ]]; then
            echo -e "\033[31m  项目根目录为空: $projects_dir\033[0m"
            echo -e "\033[33m  设置 \$CLAUDE_PROJECT_ROOT 指向你的项目目录\033[0m"
            return
        fi

        local i=1
        for d in "${dirs[@]}"; do
            local mtime=$(stat -f "%Sm" -t "%m-%d %H:%M" "$projects_dir/$d")
            printf "    [%d]  %-14s %s\n" $i "$d" "$mtime"
            ((i++))
        done
        echo ""
        
        echo -n "  输入序号或项目名（直接回车取消）: "
        read choice
        
        if [[ -z "$choice" ]]; then
            return
        fi
        
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            local idx=$((choice - 1))
            if (( idx < 0 || idx >= ${#dirs[@]} )); then
                echo -e "\033[31m  序号超出范围\033[0m"
                return
            fi
            project=${dirs[$idx]}
        else
            project=$choice
        fi
    fi

    local path="$projects_dir/$project"
    if [[ ! -d "$path" ]]; then
        echo -n "  项目不存在: $project，是否创建？(y/N) "
        read create
        if [[ "$create" == "y" || "$create" == "Y" ]]; then
            mkdir -p "$path"
            echo -e "\033[32m  已创建: $path\033[0m"
        else
            return
        fi
    fi

    cd "$path"
    echo -e "\033[32m  进入: $project\033[0m"
    claude
}

# cr - 恢复历史会话
alias cr='claude -r'

# cc - 继续当前项目上次会话
alias cc='claude -c'
