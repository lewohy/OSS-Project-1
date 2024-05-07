#!/usr/bin/env bash

print_whoami() {
    echo "************OSS1 - Project1************"
    echo "*      StudentID: 12226322            *"
    echo "*      Name: Woohyun Lee              *"
    echo "***************************************"
}

print_menu() {
    menus=(
        "Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
        "Get the team data to enter a league position in teams.csv"
        "Get the Top-3 Attendance matches in mateches.csv"
        "Get the team's league position and team's top scorer in teams.csv & players.csv"
        "Get the modified format of date_GMT in matches.csv"
        "Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
        "Exit"
    )

    local index=1

    echo
    echo "[MENU]"
    for menu in "${menus[@]}"; do
        echo "${index}. $menu"

        ((index++))
    done
}

menu1() {
    read -p "Do you want to get the Heung-Min Son's data? (y/n): " choice

    if [ "$choice" == "y" ]; then
        # 1행 제거
        # awk로 필드 구분자를 ,로 설정하고, $1이 "Heung-Min Son"인 경우에만 출력
        sed 1d $player_file | awk -F, '$1 ~ "Heung-Min Son" { printf("Team: %s, Appearance: %s, Goal: %s, Assist: %s\n", $1, $6, $7, $8) }'
    fi
}

menu2() {
    read -p "What do you want to get the team data of league_position[1~20]: " choice

    if [ "$choice" -ge 1 ] && [ "$choice" -le 20 ]; then
        # 1행 제거
        # awk로 필드 구분자를 ,로 설정하고, $6이 입력한 league_position과 같은 경우에만 출력
        sed 1d $team_file | awk -F, -v league_position=$choice '$6 == league_position { printf("%s %s %s", league_position, $1, $2 / ($2 + $3 + $4)) }'
    else
        echo "Invalid league position. Please enter a number between 1 and 20."
    fi
}

menu3() {
    read -p "Do you want to know Top-3 attendance data and average attendance? (y/n): " choice

    if [ "$choice" == "y" ]; then
        echo "***Top-3 Attendance Match***"
        echo
        # 1행 제거
        # sort로 2번째 필드를 숫자로 정렬하고, 역순으로 정렬
        # 상위 3개만 사용
        # awk로 필드 구분자를 ,로 설정하고, 출력 포맷을 설정
        sed 1d $match_file | sort -n -t, -r -k 2 | head -n 3 | awk -F, '{ printf("%s vs %s (%s)\n%s %s\n\n", $3, $4, $1, $2, $7) }'
    fi
}

menu4() {
    read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n): " choice

    if [ "$choice" == "y" ]; then
        # 1행 제거
        # sort로 6번째 필드(league_position)를 기준으로 정렬하고
        # cut으로 1번째 필드(team_name)와 6번째 필드(league_position)만 사용
        # while문으로 각 행을 읽어서 반복
        sed 1d $team_file | sort -n -t, -k 6 | cut -d, -f1,6 | while IFS=',' read -r team_name league_position; do
            echo "${league_position} ${team_name}"
            # 1행 제거
            # awk로 필드 구분자를 ,로 설정하고, $4(team_name)가 반복중인 팀 이름과 같은 경우에만 출력
            # sort로 7번째 필드(goal_overall)를 숫자로 정렬하고, 역순으로 정렬(내림차순)
            # head로 상위 1개만 사용
            # tr로 ,를 공백으로 변경하여 출력
            sed 1d $player_file | awk -F, -v team_name="$team_name" '$4 ~ team_name { printf("%s,%s\n", $1, $7) }' | sort -n -t, -r -k 2 | head -n 1 | tr ',' ' '
            echo
        done
    fi
}

menu5() {
    read -p "Do you want to modify the format of date? (y/n): " choice

    if [ "$choice" == "y" ]; then
        # sed 1d $match_file | cut -d, -f1 | awk -F' ' '{ printf("%s %s %s %s\n", $1, $2, $3, $5) }' | date -f- '+%Y/%m/%d %-l:%M%P'
        # 1행 제거
        # cut로 1번째 필드(date_GMT)만 사용
        #
        sed 1d $match_file |
            cut -d, -f1 |
            sed -E -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' -e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g' |
            sed -E -e 's/([0-9]{1,2}) ([0-9]{2}) ([0-9]{4}) - (.+)/\3\/\1\/\2 \4/g' |
            head -n 10

        # | sed -E -e 's/(\d{1,2}) (\d{1,2}) (\d{4}) - (.+)/\3\/\1\/\2 \4/g'
    fi
}

menu6() {
    declare -a team_names

    while IFS=',' read -r team_name; do
        team_names+=("$team_name")
    done < <(sed 1d "$team_file" | cut -d, -f1)

    printf "%s\n" "${team_names[@]}" | awk '{ printf("%s) %s\n", NR, $1) }' | pr -t -2

    read -p "Enter your team number: " choice

    if [ "$choice" -ge 1 ] && [ "$choice" -le "${#team_names[@]}" ]; then
        team_name=${team_names[$(($choice - 1))]}

        declare -a team_data_list
        while IFS=',' read -r date_gmt home_team away_team home_team_score away_team_score score_diff; do
            team_data_list+=("$date_gmt,$home_team,$away_team,$home_team_score,$away_team_score,$score_diff")
        done < <(sed 1d $match_file | awk -F, -v team_name="$team_name" '$3 ~ team_name { printf("%s,%s,%s,%s,%s,%s\n", $1, $3, $4, $5, $6, $5 - $6) }')

        largest_diff=$(printf "%s\n" "${team_data_list[@]}" | awk -F, '{ print $6 }' | sort -n | tail -n 1)

        printf "%s\n" "${team_data_list[@]}" | awk -F, -v largest_diff=$largest_diff '($6) == largest_diff { printf("%s,%s,%s,%s,%s\n", $1, $2, $3, $4, $5) }' | while IFS=',' read -r match_date home_team away_team home_score away_score; do
            if [ "$team_name" = "$home_team" ]; then
                echo $match_date
                echo "$home_team $home_score vs $away_score $away_team"
                echo
            fi
        done
    else
        echo "Invalid team number. Please enter a number between 1 and ${#team_names[@]}."
    fi
}

menu7() {
    echo "Bye!"
    exit 0
}

main() {
    print_whoami

    while true; do
        print_menu

        read -p "Enter your CHOICE (1~7): " choice

        if [ "$choice" -eq 1 ]; then
            menu1
        elif [ "$choice" -eq 2 ]; then
            menu2
        elif [ "$choice" -eq 3 ]; then
            menu3
        elif [ "$choice" -eq 4 ]; then
            menu4
        elif [ "$choice" -eq 5 ]; then
            menu5
        elif [ "$choice" -eq 6 ]; then
            menu6
        elif [ "$choice" -eq 7 ]; then
            menu7
        else
            echo "Invalid choice. Please enter a number between 1 and 7."
        fi
    done
}

if [ "$#" -ne 3 ]; then
    script_name=$(basename "$0")
    echo "Usage: ./${script_name} file1 file2 file3" >&2
    exit 1
fi

team_file=$1
player_file=$2
match_file=$3

main
