#!/bin/bash

#指定路径
dir_path="/home/cap/linux/records"

#关联数组，记录学生在某天是否出席
declare -A date_id

if [ -d "$dir_path" ]; then
    cd "$dir_path"  
    #逐个读取文件
    for file in *; do
        #检查是否为文件
        if [ -f "$file" ]; then
            #取日期部分，下面将日期与学生学号连接，实现一天点名两次
			#出现一次就记为出席的功能
            date_part=$(echo "$file" | cut -c 5-8)

			count=0
            #使用while循环读取当前文件
			#_是一个占位符，用于忽略后面的字段，这里只需要第一行的第一个字段
            while read -r first_field _; do
                #跳过前两行
                if [[ $count -lt 2 ]]; then
                    ((count++))
                    continue
                fi

				#跳过空行
				if [[ -z "$first_field" ]]; then
       			 	continue  
    			fi
                
                #将日期与学号连接
                result="$date_part$first_field"
                #将日期+学号进行记录
                date_id["$result"]=1
            done < "$file"
        fi
    done
else
    echo "Directory $dir_path does not exist."
	exit 0
fi

#关联数组，记录学生出席
declare -A student_count

#遍历日期+学号，取出学号，进行记录
for key in "${!date_id[@]}"; do
    id="${key:4}"

	#只在学号未出现时初始化计数器
    if [[ -z "${student_count[$id]}" ]]; then
        student_count["$id"]=0
    fi

    #增加当前学生出席次数
    student_count["$id"]=$((student_count["$id"] + 1))
done

my_id="cnet2727"

echo "attendance:"
#遍历输出 出席记录 
for key in "${!student_count[@]}"; do
	#跳过自己的学号
	if [ "$key" = $my_id ]; then
		continue
	fi
	echo "$key: ${student_count[$key]}"
done | sort -t: -k1,1
#sort -t分隔符 -k指定排序的关键字段范围

echo "This is me:"
echo "$my_id: ${student_count[$my_id]}"