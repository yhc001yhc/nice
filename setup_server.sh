#!/bin/bash

# setup_server.sh - 设置服务器来处理下载请求，并在新下载后更新地址。

# 定义文件和路径
SCRIPT_DIR="/var/www/html"
COUNTER_FILE="$SCRIPT_DIR/download_counter.txt"
SCRIPT_FILE="$SCRIPT_DIR/1.sh"
DOWNLOAD_SCRIPT="$SCRIPT_DIR/download.php"
NGINX_CONFIG="/etc/nginx/sites-available/default"
UPDATE_SCRIPT="$SCRIPT_DIR/update_address.sh"

# 创建下载计数器文件
echo 0 > $COUNTER_FILE

# 创建 PHP 下载脚本
cat <<EOF > $DOWNLOAD_SCRIPT
<?php
// download.php
//
// // 文件和路径定义
$counterFile = '/var/www/html/download_counter.txt';
$scriptFile = '/var/www/html/1.sh';
$logfile = '/var/www/html/update_script.log'; // 定义日志文件的路径
$UPDATE_SCRIPT = "/var/www/html/update_address.sh"; // 给出 update_address.sh 脚本的正确路径
//
// // 确保计数器文件存在
if (!file_exists($counterFile)) {
     file_put_contents($counterFile, 0);
}
//
//     // 读取当前计数器，并加一表示新的下载载
$counter = (int)file_get_contents($counterFile); 
$counter++; 
file_put_contents($counterFile, $counter);
// 如果是第一次下载，则不执行地址更新脚本
if ($counter > 1) {
    // 执行供下载前地址更新的脚本，并将输出保存至日志文件 注意：这里同时记录了标准输出和标准错误
    $cmd = "/bin/bash " . escapeshellarg($UPDATE_SCRIPT) . " 2>&1"; 
    $output = shell_exec($cmd);
    
    // 将输出追加到日志文件中，包括执行的时间戳
    file_put_contents($logfile, "[".date('Y-m-d H:i:s')."] - Executing: $cmd\n$output\n\n", FILE_APPEND);
}
// 设置文件提供下载
header('Content-Type: application/octet-stream'); 
header('Content-Disposition: attachment; filename="' . basename($scriptFile) . '"'); 
readfile($scriptFile);
?>
EOF

# 赋予 PHP 脚本正确的权限
chown www-data:www-data $DOWNLOAD_SCRIPT
chmod 755 $DOWNLOAD_SCRIPT

# 确保 nginx 配置文件中存在用于重写规则的位置块
# 上述 sed 表达式会找到配置文件中 location / { 这行然后在其前面插入新的重定向规则
if ! grep -q "^ *rewrite ^/1.sh$ /download.php last;" $NGINX_CONFIG; then
   sed -i "/location \/ {/i location ~ \^\/1\.sh\$ {\n\trewrite ^/1.sh$ /download.php last;\n}" $NGINX_CONFIG
fi

# 重启 nginx 以应用新配置
nginx -t && systemctl restart nginx