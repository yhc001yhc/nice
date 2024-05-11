#!/bin/bash
# update_address.sh
# 获取新的钱包地址，并更新到1.sh中

ADDRESS_FILE="/var/www/html/3000.txt"
TMP_FILE="/home/debian/3000.tmp"
SCRIPT_FILE="/var/www/html/1.sh"
LOG_FILE="/var/www/html/update_address.log" # 指定日志文件路径

# 记录当前日期和时间
echo "更新操作于 $(date) 开始：" >> "$LOG_FILE"

# 从列表顶部获取一个新的钱包地址
NEW_ADDRESS=$(head -n 1 "$ADDRESS_FILE")

# 检查地址是否获取成功
if [ -z "$NEW_ADDRESS" ]; then
    echo "无法获取新的钱包地址！" >> "$LOG_FILE"
    exit 1
fi

# 在1.sh脚本中将钱包地址更新为新的地址
sed -i "s/WITHDRAW_ADDRESS=\".*\"/WITHDRAW_ADDRESS=\"$NEW_ADDRESS\"/" "$SCRIPT_FILE"

# 记录更新的地址
echo "钱包地址已更新为: $NEW_ADDRESS" >> "$LOG_FILE"

# 把已使用的地址放到列表的底部，并更新地址文件
tail -n +2 "$ADDRESS_FILE" > "$TMP_FILE"
echo "$NEW_ADDRESS" >> "$TMP_FILE"
mv "$TMP_FILE" "$ADDRESS_FILE"

# 记录地址列表更新操作
echo "地址列表已更新，旧地址已移至文件末尾。" >> "$LOG_FILE"