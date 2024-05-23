#!/bin/bash

function password_protect() {
    local USER_PASSWORD="pingpong121"  # 设置密码，实际使用时应更安全地处理
    read -sp "请输入密码以继续: " input_password  # 提示用户输入密码
    echo
    if [ "$input_password" != "$USER_PASSWORD" ]; then
        echo "密码错误，退出脚本。"
        exit 1
    fi
}

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 节点安装功能
function install_node() {

# 更新系统包列表
sudo apt update
apt install screen -y

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null
then
    # 如果 Docker 未安装，则进行安装
    echo "未检测到 Docker，正在安装..."
    sudo apt-get install ca-certificates curl gnupg lsb-release

    # 添加 Docker 官方 GPG 密钥
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # 设置 Docker 仓库
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 授权 Docker 文件
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    sudo apt-get update

    # 安装 Docker 最新版本
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
else
    echo "Docker 已安装。"
fi

#获取运行文件
read -p "请输入你的key device id: " your_device_id

keyid="$your_device_id"

# 下载PINGPONG程序
wget -O PINGPONG https://pingpong-build.s3.ap-southeast-1.amazonaws.com/linux/latest/PINGPONG

if [ -f "./PINGPONG" ]; then
    chmod +x ./PINGPONG
    screen -dmS pingpong bash -c "./PINGPONG --key \"$keyid\""
else
    echo "下载PINGPONG失败，请检查网络连接或URL是否正确。"
fi

 echo "节点已经启动，请使用screen -r pingpong 查看日志或使用脚本功能2"

}

function check_service_status() {
    screen -r pingpong
}

function reboot_pingpong() {
    read -p "请输入你的key device id: " your_device_id
    keyid="$your_device_id"
    screen -dmS pingpong bash -c "./PINGPONG --key \"$keyid\""
}


# 主菜单
function main_menu() {
    clear
    echo "Made by Bond Node Community"
    echo "欢迎部署pingpong节点"
    echo "=====================安装及常规修改功能========================="
    echo "Join Bond Node Community, go go go"
    echo "节点社区 Discord:https://discord.gg/ecJq3NBE6M"

    echo "请选择要执行的操作:"
    echo "1. 安装节点"
    echo "2. 查看节点日志"
    echo "3. 重启pingpong"
    read -p "请输入选项（1-3）: " OPTION

    case $OPTION in
    1) 
	password_protect
	install_node ;;
    2) check_service_status ;;
    3) reboot_pingpong ;; 
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu
