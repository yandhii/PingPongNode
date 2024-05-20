#!/bin/bash
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
    sudo apt-get update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    sudo systemctl status docker
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
else
    echo "Docker 已安装。"
fi

#获取运行文件
read -p "请输入你的key device id: " your_device_id

keyid="$your_device_id"

# 下载PINGPONG程序
mkdir pingpong && cd pingpong
curl -O https://pingpong-build.s3.ap-southeast-1.amazonaws.com/linux/latest/PINGPONG

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
    echo "请选择要执行的操作:"
    echo "1. 安装节点"
    echo "2. 查看节点日志"
    echo "3. 重启pingpong"
    read -p "请输入选项（1-3）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) check_service_status ;;
    3) reboot_pingpong ;; 
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu
