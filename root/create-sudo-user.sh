#!/bin/bash
# 快速创建用户并加入 sudo 组

if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行"
    exit 1
fi

read -p "请输入用户名: " username

# 如果用户存在，先删除
if id "$username" &>/dev/null; then
    echo "用户 $username 已存在，正在删除..."
    userdel -r "$username" 2>/dev/null
fi

# 创建用户
useradd -m -s /bin/bash "$username"
echo "请输入密码："
passwd "$username"

# 加入 sudo 组
usermod -aG sudo "$username"

echo "✅ 用户 $username 创建成功并已加入 sudo 组"
id "$username"
